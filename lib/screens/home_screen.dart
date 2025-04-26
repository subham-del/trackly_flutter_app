import 'package:flutter/material.dart';
import 'package:trackly/screens/map_screen.dart';
import 'package:trackly/screens/profile_screen.dart';
import 'discover_screen.dart';
import 'friends_screen.dart';
import 'notifications_screen.dart';

class homeScreen extends StatefulWidget {
  const homeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<homeScreen> {
  int _currentIndex = 0;



  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      MapScreen(),
      FriendsScreen(),
      NotificationsScreen(),
      DiscoverScreen(),
    ];

    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfileScreen()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(
                  'https://i.pravatar.cc/300', // Replace with your user's profile image URL
                ),
              ),
            ),
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: Colors.blue.shade100,
          labelTextStyle: MaterialStateProperty.all(
            TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
        child: NavigationBar(
          height: 60,
          backgroundColor: Color(0xFFf1f5fb),
          selectedIndex: _currentIndex,
          onDestinationSelected:
              (_currentIndex) => setState(() {
                this._currentIndex = _currentIndex;
              }),
          destinations: [
            NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.people), label: 'Friends'),
            NavigationDestination(
              icon: Icon(Icons.notifications),
              label: 'Notifications',
            ),
            NavigationDestination(icon: Icon(Icons.explore), label: 'Discover'),
          ],
        ),
      ),
    );
    throw UnimplementedError();
  }
}
