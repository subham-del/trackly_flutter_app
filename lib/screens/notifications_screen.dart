import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      children: const [
        SizedBox(height: 48),
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Notifications Tab', style: TextStyle(fontSize: 24)),
        ),
      ],
    );
    throw UnimplementedError();
  }

}