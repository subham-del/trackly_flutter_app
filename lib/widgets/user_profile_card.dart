import 'dart:math';

import 'package:flutter/material.dart';

class UserProfileCard extends StatelessWidget {
  final int userId;
  final String userName;
  final VoidCallback onRequestSent;

  const UserProfileCard({
    super.key,
    required this.userId,
    required this.userName,
    required this.onRequestSent,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0), // no rounded corners
        side: BorderSide.none,                  // no border
      ),
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(
              'https://i.pravatar.cc/300?u=$userId'
          ),
        ),
        title: Text(userName),
        trailing: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // <-- set radius here
            ),
          ),
          onPressed: onRequestSent,
          icon: Icon(Icons.person_add),
          label: const Text('Add'),
        ),
      ),
    );
  }
}
