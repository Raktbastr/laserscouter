// login.dart
import 'package:flutter/material.dart';

class EventPicker extends StatelessWidget {
  const EventPicker({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 19, 81, 179), 
        iconTheme: const IconThemeData(color: Colors.white), 
      ),
      body: Center(
        child: Text('Login Page Content'),
      ),
    );
  }
}