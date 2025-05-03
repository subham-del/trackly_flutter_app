import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:trackly/services/notification_service.dart';
import 'package:trackly/services/storage_service.dart';
import '../models/user/friend_model.dart';
import '../screens/home_screen.dart';
import '../services/auth_service.dart';
import '../services/web_socket_service.dart';
import '../utils/tracking_manager.dart'; // <-- Import this

class FriendCard extends StatefulWidget {
  final Friend friend;

  const FriendCard({super.key, required this.friend});

  @override
  State<FriendCard> createState() => _FriendCardState();
}

class _FriendCardState extends State<FriendCard> {

  @override
  Widget build(BuildContext context) {
    final isTracking = TrackingManager().isTracking(widget.friend.friendId);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      color: Colors.white,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(
                'https://i.pravatar.cc/300?u=${widget.friend.friendId}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.friend.friendName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (isTracking) {
                  stopTrackingRequest(widget.friend.friendId);
                } else {
                  sendTrackingRequest(widget.friend.friendId);
                }
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(isTracking ? 'Stop' : 'Track'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> sendTrackingRequest(int userBId) async {
    currentTabNotifier.value = 0;
    final senderUserName = await TokenStorage.getUsername();
    final senderUserId = await TokenStorage.getUserId();

    final response = await NotificationService().notifyUser(
      userBId,
      "$senderUserName is tracking you! Please open the app.",
    );

    if (response.statusCode == 200) {
      print('Notification sent to User B');
      WebSocketService().send({
        "type": "trackUser",
        "userId": senderUserId,
        "targetUserId": userBId,
      });

      TrackingManager().startTracking(userBId);
      setState(() {});
    } else {
      print('Failed to send notification');
    }
  }

  Future<void> stopTrackingRequest(int userBId) async {
    final senderUserId = await TokenStorage.getUserId();
    final senderUserName = await TokenStorage.getUsername();
    WebSocketService().send({
      "type": "stopTracking",
      "from": senderUserId,
      "fromUserName": senderUserName,
      "to": userBId,
    });

    TrackingManager().stopTracking(userBId);
    setState(() {});
    print('Stopped tracking user $userBId');
  }
}
