import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static final _storage = FlutterSecureStorage();

  //token
  static Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: 'accessToken', value: accessToken);
    await _storage.write(key: 'refreshToken', value: refreshToken);
  }

  static Future<String?> getAccessToken() => _storage.read(key: 'accessToken');
  static Future<String?> getRefreshToken() => _storage.read(key: 'refreshToken');

  static Future<void> clearTokens() async {
    await _storage.delete(key: 'accessToken');
    await _storage.delete(key: 'refreshToken');
  }



  //user
  static Future<void> saveUser(String id, String username) async {
    await _storage.write(key: 'userId', value: id);
    await _storage.write(key: 'username', value: username);
  }

  static Future<String?> getUserId() => _storage.read(key: 'userId');
  static Future<String?> getUsername() => _storage.read(key: 'username');

  static Future<void> clearUser() async {
    await _storage.delete(key: 'userId');
    await _storage.delete(key: 'username');
  }
}

