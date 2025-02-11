import 'package:flutter/material.dart';
import 'package:hrms/camera.dart';
import 'package:hrms/homepage.dart';
import 'package:hrms/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/admin_dashboard': (context) => AdminDashboard(),
        '/user_dashboard': (context) => HRDashboard(),
        '/manager_dashboard': (context) => ManagerDashboard(),
        '/home': (context) => FrontPage(),
      },
    );
  }
}
