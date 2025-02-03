// login.dart
import 'package:flutter/material.dart';
import 'login.dart';

class EventPicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 19, 81, 179), 
        iconTheme: const IconThemeData(color: Colors.white), 
      ),
    );
  } // Call the function with the apiKey
}