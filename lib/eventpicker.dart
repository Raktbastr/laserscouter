// eventpicker.dart
import 'package:flutter/material.dart';
import 'teampicker.dart';

class EventPicker extends StatelessWidget {
  final List<String> eventNames;
  final List<String> eventCodes;
  final String apiKey;

  EventPicker({required this.eventNames, required this.eventCodes, required this.apiKey});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 19, 81, 179), 
        iconTheme: const IconThemeData(color: Colors.white), 
      ),
      body: ListView.builder(
        itemCount: eventNames.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(eventNames[index]),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TeamPicker(
                    apiKey: apiKey,
                    eventCode: eventCodes[index],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}