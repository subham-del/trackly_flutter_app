import 'package:flutter/material.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      children: const [
        Text('', style: TextStyle(fontSize: 24)),
        // ... more content
      ],
    );
    throw UnimplementedError();
  }

}