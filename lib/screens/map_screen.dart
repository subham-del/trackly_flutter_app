import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/web_socket_service.dart';
import 'home_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  LatLng _initialPosition = const LatLng(20.5937, 78.9629);

  final Map<int, Marker> userMarkers = {};

  @override
  void initState() {
    super.initState();

    WebSocketService().onLocationReceived = (lat, lng, userId) {
      print("location updated");
      _updateUserMarker(LatLng(lat, lng), userId);
      if (trackingStatusNotifier.value == TrackingStatus.waiting) {
        trackingStatusNotifier.value = TrackingStatus.active;
      }
    };

    WebSocketService().onStopTracking = (userId) {
      final parsedId = int.tryParse(userId.toString());
      if (parsedId != null) {
        _removeUserMarker(parsedId);
      }
    };
  }

  Future<BitmapDescriptor> _createCircularMarkerIcon(String imageUrl, {String username = 'User'}) async {
    final ImageProvider imageProvider = NetworkImage(imageUrl);
    final Completer<ui.Image> completer = Completer();
    final imageStream = imageProvider.resolve(const ImageConfiguration());
    final listener = ImageStreamListener((ImageInfo info, bool _) {
      completer.complete(info.image);
    });
    imageStream.addListener(listener);
    final ui.Image image = await completer.future;
    imageStream.removeListener(listener);

    const double width = 200;
    const double height = 240;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..isAntiAlias = true;

    // Draw username text
    final textPainter = TextPainter(
      text: TextSpan(
        text: username,
        style: const TextStyle(
          fontSize: 28, // Increased font size
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(minWidth: 0, maxWidth: width);
    textPainter.paint(canvas, Offset((width - textPainter.width) / 2, 10));

    // Draw circular image below the text
    const circleDiameter = 150.0;
    final imageTop = 60.0;
    canvas.drawCircle(
      Offset(width / 2, imageTop + circleDiameter / 2),
      circleDiameter / 2,
      paint,
    );
    paint.blendMode = BlendMode.srcIn;
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH((width - circleDiameter) / 2, imageTop, circleDiameter, circleDiameter),
      paint,
    );

    final picture = recorder.endRecording();
    final img = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(pngBytes);
  }


  void _updateUserMarker(LatLng position, int userId) async {
    final imageUrl = 'https://i.pravatar.cc/300?u=$userId';
    final username = 'User $userId'; // Replace with actual name if available

    final icon = await _createCircularMarkerIcon(imageUrl, username: username);

    setState(() {
      userMarkers[userId] = Marker(
        markerId: MarkerId('$userId'),
        position: position,
        icon: icon,
        anchor: const Offset(0.5, 1),
      );
    });

    _mapController.animateCamera(CameraUpdate.newLatLngZoom(position, 16));
  }

  void _removeUserMarker(int userId) {
    setState(() {
      userMarkers.remove(userId);
    });
  }

  @override
  void dispose() {
    WebSocketService().onLocationReceived = null;
    WebSocketService().onStopTracking = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TrackingStatus>(
      valueListenable: trackingStatusNotifier,
      builder: (context, status, _) {
        return Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(target: _initialPosition, zoom: 6),
              onMapCreated: (controller) {
                _mapController = controller;
              },
              markers: Set<Marker>.from(userMarkers.values),
            ),
            if (status == TrackingStatus.waiting)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        );
      },
    );
  }
}
