import 'package:flutter/material.dart';

class UserProfileCard extends StatelessWidget {

  final String userName;
  final VoidCallback onRequestSent;

  const UserProfileCard({
    super.key,
    required this.userName,
    required this.onRequestSent,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(
            'https://ui-avatars.com/api/?name=${Uri.encodeComponent(userName)}&background=random',
          ),
        ),
        title: Text(userName),
        trailing: ElevatedButton(
          onPressed: onRequestSent,
          child: const Text('Add'),
        ),
      ),
    );
  }
}
