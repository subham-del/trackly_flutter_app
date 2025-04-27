import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:trackly/models/user/user.dart';
import 'package:trackly/services/storage_service.dart';
import '../services/auth_service.dart';
import '../widgets/user_profile_card.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  _DiscoverScreenState createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final authHttp = AuthHttpService(baseUrl: 'http://${dotenv.env['BACKEND_URL']}:3000');

  static const limit = 15;
  bool hasMore = true;
  int page = 0;
  bool isLoading = false;
  bool get _isBottom {
    if (!controller.hasClients) return false;
    final maxScroll = controller.position.maxScrollExtent;
    final currentScroll = controller.position.pixels;
    return currentScroll >= (maxScroll - 200);
  }
  final controller = ScrollController();
  List<User> users = [];



 @override
  void initState() {
    // TODO: implement initState
   super.initState();
   WidgetsBinding.instance.addPostFrameCallback((_) {
     fetch(); // Fetch only once layout is done
   });

   controller.addListener(() {
     if (_isBottom && hasMore && !isLoading) {
       fetch();
     }
   });
  }

  Future fetch() async{
   if(isLoading) return;
   isLoading = true;
    try {
      final userId = await TokenStorage.getUserId();
      final response = await authHttp.get('/api/users/$userId?page=$page&limit=$limit');
      if (response.statusCode == 200) {
        final jsonRes = jsonDecode(response.body);
        List<dynamic> profilesList = jsonRes['profiles'];
        setState(() {
          page++;
          isLoading = false;
          if(profilesList.length < limit){
            hasMore = false;
          }
          users.addAll(profilesList.map((item) => User.fromJson(item as Map<String, dynamic>)).toList());
        });
      } else {
        print('Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator( onRefresh: refresh,child: ListView.builder(controller: controller, itemCount: users.length + 1, itemBuilder: (context, index){
      if(index < users.length){
        final user = users[index];
        return UserProfileCard(userId: user.userId!,userName: user.username!, onRequestSent: () async{
          final userId = await TokenStorage.getUserId();
          final response = await authHttp.post(
            '/api/users/friend-request',
            {
              'senderId': userId,
              'receiverId': user.userId,
            },
          );
          final res = jsonDecode(response.body);
          if (response.statusCode == 201) {

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(res['message'])),
            );
            refresh();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(res['message'])),
            );
          }
        });
      }
      else{
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Center(child: hasMore? CircularProgressIndicator() : const Text('No more data to load'),),
        );
      }
    }));
  }

  Future refresh() async{
    setState(() {
      isLoading = false;
      hasMore = true;
      page = 0;
      users.clear();
    });

    await fetch();
  }

}
