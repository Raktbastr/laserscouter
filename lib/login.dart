import 'package:flutter/material.dart';
import 'eventpicker.dart'; 
import 'package:http/http.dart' as http; 
import 'dart:convert'; 

void getData(String apiKey, String teamNumber, Function(List<String>, List<String>) callback) async {
  final response = await http.get(
    Uri.parse('https://www.thebluealliance.com/api/v3/team/frc$teamNumber/events/2025'),
    headers: {
      'X-TBA-Auth-Key': apiKey,
    },
  );
  if (response.statusCode == 200) {
    String data = response.body;
    var decodedData = jsonDecode(data);
    List<String> eventNames = [];
    List<String> eventCodes = [];

    for (var event in decodedData) {
      eventNames.add(event['name']);
      eventCodes.add(event['key']);
    }
    callback(eventNames, eventCodes);
  } else {
    print(response.statusCode);
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Page',
      theme: ThemeData(
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          iconTheme: IconThemeData(color: Colors.white), 
        ),
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _teamNumberController = TextEditingController();
  final TextEditingController _apiKeyController = TextEditingController();

  @override
  void dispose() {
    _teamNumberController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 19, 81, 179),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/laserscouterlogo.png', height: 100),
            const SizedBox(height: 16.0),
            TextField(
              controller: _teamNumberController,
              decoration: const InputDecoration(
                labelText: 'Team Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _apiKeyController,
              decoration: const InputDecoration(
                labelText: 'TBA API Key',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                String teamNumber = _teamNumberController.text;
                String apiKey = _apiKeyController.text;
                getData(apiKey, teamNumber, (eventNames, eventCodes) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventPicker(
                      eventNames: eventNames,
                      eventCodes: eventCodes,
                      apiKey: apiKey,
                      ),
                    ),
                  );
                });
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
