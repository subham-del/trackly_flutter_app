import 'package:flutter/material.dart';

import 'package:trackly/screens/Login.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:trackly/screens/home_screen.dart';
import 'package:trackly/services/auth_service.dart';
import 'package:trackly/services/storage_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  await dotenv.load(); // Load the .env file
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      routes: {
        '/login': (context) => const Login(),

      },
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final authHttp = AuthHttpService(
    baseUrl: 'http://${dotenv.env['BACKEND_URL']}:3000',
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkLoginStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('')));
  }

  Future<void> _checkLoginStatus() async {
    final accessToken = await TokenStorage.getAccessToken();

    if (accessToken != null) {
      final response = await authHttp.get('/api/auth/me');

      if (response.statusCode == 200) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => homeScreen()));
      }
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Login()));
    }
  }
}
