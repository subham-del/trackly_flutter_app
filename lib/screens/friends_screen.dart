import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:trackly/services/storage_service.dart';

import '../models/user/friend_model.dart';
import '../services/auth_service.dart';
import '../widgets/friend_card.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen>
    with SingleTickerProviderStateMixin {

  final authHttp = AuthHttpService(baseUrl: 'http://${dotenv.env['BACKEND_URL']}:3000');
  late Future<List<Friend>> friendsFuture;
  late Future<List<Map<String, dynamic>>> requestsFuture;
  late TabController _tabController;
  int friendsCount = 0;
  int requestsCount = 0;

  Future<void> fetchCounts() async {
    // Replace with actual API call
    final currentUserId = await TokenStorage.getUserId();
    final response = await authHttp.get('/api/users/friend-requests/count/$currentUserId');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
      setState(() {
        requestsCount = data['TotalFriendRequests'];
        friendsCount = data['TotalFriends'];
      });

    } else {
      throw Exception('Failed to load friend requests');
    }


  }

  @override
  void initState(){
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    friendsFuture = fetchFriends();
    requestsFuture = fetchFriendRequests();
    fetchCounts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SafeArea(
      child: Column(
        children: [
          Container(
             // Match your theme color if needed
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.black,
              indicatorColor: Colors.black,
              tabs: [
                Tab(text: 'Friends ($friendsCount)'),
                Tab(text: 'Requests ($requestsCount)'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [buildFriendsList(), buildRequestsList()],
            ),
          ),
        ],
      ),
    );
    throw UnimplementedError();
  }

  Widget buildFriendsList() {
    return  FutureBuilder<List<Friend>>(
      future: friendsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator()); // loading
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}')); // error
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No friends found')); // no data
        } else {
          final friends = snapshot.data!;
          return ListView.builder(
            itemCount: friends.length,
            itemBuilder: (context, index) {
              final friend = friends[index];
              return FriendCard(friend: friend);
            },
          );
        }
      },
    );
  }

  Widget buildRequestsList() {

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: requestsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No friend requests'));
        }

        final requests = snapshot.data!;
        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // rounded corners
              ),
              elevation: 4, // shadow
              child: Padding(
                padding: const EdgeInsets.all(12.0), // inner padding inside the card
                child: ListTile(
                  title: Text(
                    request['SenderUsername'],
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          acceptFriendRequest(request['RequestId']);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          minimumSize: Size(70, 36),
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8), // buttons also rounded
                          ),
                        ),
                        child: Text(
                          'Accept',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          // Reject friend request
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          minimumSize: Size(70, 36),
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Reject',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );


          },
        );
      },
    );
  }


  Future<List<Map<String, dynamic>>> fetchFriendRequests() async {
    final currentUserId = await TokenStorage.getUserId();
    final response = await authHttp.get('/api/users/friend-requests/$currentUserId');
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load friend requests');
    }
  }


  Future<List<Friend>> fetchFriends() async {
    final currentUserId = await TokenStorage.getUserId();
    final response = await authHttp.get(
      '/api/users/friends/$currentUserId' // Replace with your backend URL
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Friend.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load friends');
    }
  }


  void acceptFriendRequest(int requestId) async {
    final response = await authHttp.post(
      '/api/users/accept-friend-request',
      { 'requestId': requestId },
    );

    if (response.statusCode == 200) {
      refreshAfterAccept();
      print('Friend request accepted!');
      // Refresh the screen if needed
    } else {
      print('Failed to accept friend request');
    }
  }

  void refreshAfterAccept() {
    // Refresh both lists
    setState(() {
      friendsFuture = fetchFriends();
      requestsFuture = fetchFriendRequests();
    });
    // Move to Friends tab
    _tabController.index = 0;
  }

}
