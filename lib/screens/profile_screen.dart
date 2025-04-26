import 'package:flutter/material.dart';
import 'package:trackly/screens/Login.dart';
import 'package:trackly/services/storage_service.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('My Profile')),
        body: Center(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding:const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: MediaQuery
                    .of(context)
                    .size
                    .width * 0.9,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // <-- set radius here
                    ),
                  ),
                  onPressed: () async {
                    await TokenStorage.clearTokens();
                    await TokenStorage.clearUser();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => Login()),
                    );
                  },
                  child: Text('logout'),
                ),
              ),
            ),
          ),
        ));
  }
}
