import 'package:flutter/material.dart';
import 'login.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laser Scouter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Ocraextended',
      ),
      home: LoginPage(),
    );
  }
}