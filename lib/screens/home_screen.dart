import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:trackly/screens/map_screen.dart';
import 'package:trackly/screens/profile_screen.dart';
import '../services/notification_service.dart';
import '../services/web_socket_service.dart';
import 'discover_screen.dart';
import 'friends_screen.dart';
import 'notifications_screen.dart';
import 'package:permission_handler/permission_handler.dart';

enum TrackingStatus { idle, waiting, active }

// Global notifiers for tab switching and tracking state
final ValueNotifier<int> currentTabNotifier = ValueNotifier(0);
final ValueNotifier<TrackingStatus> trackingStatusNotifier = ValueNotifier(
  TrackingStatus.idle,
);

class homeScreen extends StatefulWidget {
  const homeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<homeScreen> {
  final notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    initBackgroundExecution();
    _connectWebSocket();
    notificationService.init();
    requestNotificationPermission();
  }

  void _connectWebSocket() async {
    await WebSocketService().connect();
  }

  Future<void> initBackgroundExecution() async {
    final androidConfig = FlutterBackgroundAndroidConfig(
      notificationTitle: "Trackly Running",
      notificationText: "Keeping connection alive...",
      notificationImportance: AndroidNotificationImportance.normal,
      enableWifiLock: true,
    );
    await FlutterBackground.initialize(androidConfig: androidConfig);
    await FlutterBackground.enableBackgroundExecution();
  }

  Future<void> requestNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      MapScreen(),
      FriendsScreen(),
      NotificationsScreen(),
      DiscoverScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfileScreen()),
              );
            },
            child: const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage('https://i.pravatar.cc/300'),
              ),
            ),
          ),
        ],
      ),
      body: ValueListenableBuilder<int>(
        valueListenable: currentTabNotifier,
        builder: (context, index, _) => _screens[index],
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: Colors.blue.shade100,
          labelTextStyle: MaterialStateProperty.all(
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
        child: ValueListenableBuilder<int>(
          valueListenable: currentTabNotifier,
          builder:
              (context, index, _) => NavigationBar(
                height: 60,
                backgroundColor: Colors.transparent,
                labelBehavior:
                    NavigationDestinationLabelBehavior.onlyShowSelected,
                selectedIndex: index,
                onDestinationSelected: (i) => currentTabNotifier.value = i,
                destinations: const [
                  NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
                  NavigationDestination(
                    icon: Icon(Icons.people),
                    label: 'Friends',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.notifications),
                    label: 'Notifications',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.explore),
                    label: 'Discover',
                  ),
                ],
              ),
        ),
      ),
    );
  }
}
