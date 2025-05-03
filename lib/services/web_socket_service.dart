import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:location/location.dart';
import 'package:trackly/services/storage_service.dart';
import 'package:web_socket_channel/io.dart';
import 'auth_service.dart';
import 'notification_service.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();

  factory WebSocketService() {
    return _instance;
  }

  WebSocketService._internal();
  final authHttp = AuthHttpService(
    baseUrl: 'http://${dotenv.env['BACKEND_URL']}:3000',
  );
  late IOWebSocketChannel _channel;
  final notificationService = NotificationService();
  Function(double, double, dynamic)? onLocationReceived;
  Function(String)? onStopTracking;
  bool _isConnected = false;
  final Map<String, StreamSubscription<LocationData>> _locationSubscriptions = {};
  final Map<String, String?> _activeTrackingUserIds = {}; // Track active users


  Future<void> connect() async {
    if (_isConnected) return;

    final url = 'ws://${dotenv.env['BACKEND_URL']}:3000';
    _channel = IOWebSocketChannel.connect(url);

    final userId = await TokenStorage.getUserId();
    if (userId != null) {
      _channel.sink.add(jsonEncode({
        'type': 'register',
        'userId': userId,
      }));
      print("WebSocketService: User $userId registered.");
    }

    _isConnected = true; // <<<<< Important!

    _channel.stream.listen(
          (message) async {
            print('WebSocket raw message: $message');
        try {
          final decoded = jsonDecode(message);

          if (decoded is Map<String, dynamic>) {
            final type = decoded['type'];
            final notification = decoded['notification'];

            if (type == 'notification' && notification != null) {
              await notificationService.showNotification(
                "Tracking Alert",
                notification,
              );
            }


            if (type == 'startLocationSharing') {
              final toUserId = decoded['toUserId'];
              if (toUserId != null) {
                _startSendingLocation(toUserId);
              }
            }


            if (type == 'locationUpdate') {
              final userId = int.tryParse(decoded['fromUserId'].toString());
              onLocationReceived?.call(decoded['lat'], decoded['lng'], userId);
              // Update map or call a callback with new LatLng(lat, lng)
            }


            if (type == 'stopSendingLocation') {
              final fromUserId = decoded['from'];
              final toUserId = decoded['to'];
              final fromUserName = decoded['fromUserName'];
              _stopSendingLocation(fromUserId, fromUserName, toUserId);
              onStopTracking?.call(fromUserId);
            }
          } else {
            print('Unexpected WebSocket message format: $decoded');
          }
        } catch (e) {
          print('Error decoding WebSocket message: $e');
        }
      },
      onError: (error) {
        print('WebSocket error: $error');
      },
      onDone: () {
        print('WebSocket connection closed by server.');
        _isConnected = false;
      },
      cancelOnError: true,
    );
  }

  void send(Map<String, dynamic> data) {
    if (_isConnected) {
      _channel.sink.add(jsonEncode(data));
    } else {
      print('WebSocket not connected. Cannot send.');
    }
  }

  void disconnect() {
    if (_isConnected) {
      _channel.sink.close();
      _isConnected = false;
      print('WebSocketService: Connection closed manually.');
    }
  }


  void _startSendingLocation(String toUserId) async {
    final userId = await TokenStorage.getUserId();
    final _location = Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) return;
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) return;
    }

    _location.changeSettings(interval: 5000);
    final locationSubscription = _location.onLocationChanged.listen((locData) {
      _channel.sink.add(jsonEncode({
        'type': 'locationUpdate',
        'userId': userId,
        'toUserId': toUserId,
        'lat': locData.latitude,
        'lng': locData.longitude,
      }));
    });

    // Store the subscription for this user
    _locationSubscriptions[toUserId] = locationSubscription;
    _activeTrackingUserIds[toUserId] = toUserId;
  }

  void _stopSendingLocation(String fromUserId, String fromUserName, int toUserId) async {
    final subscription = _locationSubscriptions[fromUserId];

    if (subscription != null) {
      await subscription.cancel();
      _locationSubscriptions.remove(fromUserId);
      _activeTrackingUserIds.remove(fromUserId);
      await notificationService.notifyUser(toUserId, "$fromUserName stopped tracking you");
      print('Stopped tracking user: $fromUserId');
    }
  }

}
