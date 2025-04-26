import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:trackly/services/storage_service.dart';

import '../main.dart';

class AuthHttpService {
  final String baseUrl;

  AuthHttpService({required this.baseUrl});

  // ===================== PRIVATE =====================

  Future<String?> _refreshAccessToken() async {
    final refreshToken = await TokenStorage.getRefreshToken();
    if (refreshToken == null) return null;

    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );

    if (response.statusCode == 200) {
      final res = jsonDecode(response.body);
      final newToken = res['accessToken'];
      await TokenStorage.saveTokens(res['accessToken'], res['refreshToken']);
      return newToken;
    }

    return null;
  }

  Future<http.Response> _retryRequest(
    http.Request request,
    String? newAccessToken,
  ) async {
    final clonedRequest = _cloneRequest(request, accessToken: newAccessToken);
    final streamed = await clonedRequest.send();
    return await http.Response.fromStream(streamed);
  }

  Future<http.Response> _sendRequest(http.Request request) async {
    final accessToken = await TokenStorage.getAccessToken();
    request.headers['Authorization'] = 'Bearer $accessToken';
    request.headers['Content-Type'] = 'application/json';

    final streamed = await request.send();
    var response = await http.Response.fromStream(streamed);

    if (response.statusCode == 403) {
      final newToken = await _refreshAccessToken();
      if (newToken != null) {
        return _retryRequest(request, newToken);
      } else {
        await TokenStorage.clearTokens(); // Clear old tokens

        // Navigate to Login screen
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
    }

    return response;
  }

  http.Request _cloneRequest(http.Request original, {String? accessToken}) {
    final newRequest = http.Request(original.method, original.url)
      ..headers.addAll(original.headers);

    // Only assign body if it's not a GET request
    if (original.method != 'GET') {
      newRequest.body = original.body;
    }

    if (accessToken != null) {
      newRequest.headers['Authorization'] = 'Bearer $accessToken';
    }

    return newRequest;
  }

  // ===================== PUBLIC =====================

  Future<http.Response> get(String endpoint) async {
    final request = http.Request('GET', Uri.parse('$baseUrl$endpoint'));
    return _sendRequest(request);
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final request = http.Request('POST', Uri.parse('$baseUrl$endpoint'))
      ..body = jsonEncode(body);
    return _sendRequest(request);
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    final request = http.Request('PUT', Uri.parse('$baseUrl$endpoint'))
      ..body = jsonEncode(body);
    return _sendRequest(request);
  }

  Future<http.Response> delete(String endpoint) async {
    final request = http.Request('DELETE', Uri.parse('$baseUrl$endpoint'));
    return _sendRequest(request);
  }
}
