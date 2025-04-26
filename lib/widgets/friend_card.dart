import 'package:flutter/material.dart';

import '../models/user/friend_model.dart';

class FriendCard extends StatelessWidget {
  final Friend friend;

  const FriendCard({Key? key, required this.friend}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                friend.friendName,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Handle Track button pressed
                print('Track ${friend.friendName}');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Track'),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'LocationHistory') {
                  // Handle location history clicked
                  print('Location History of ${friend.friendName}');
                }
              },
              itemBuilder: (context) =>
              [
                PopupMenuItem(
                  value: 'LocationHistory',
                  child: Text('Location History'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}