import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void getData(String apiKey, String eventCode, Function(List<String>, List<String>) callback) async {
  final response = await http.get(
    Uri.parse('https://www.thebluealliance.com/api/v3/event/$eventCode/teams'),
    headers: {
      'X-TBA-Auth-Key': apiKey,
    },
  );
  if (response.statusCode == 200) {
    String data = response.body;
    var decodedData = jsonDecode(data);
    List<String> teamNames = [];
    List<String> teamCodes = [];

    for (var event in decodedData) {
      teamNames.add(event['nickname']);
      teamCodes.add(event['team_number'].toString());
    }
    callback(teamNames, teamCodes);
  } else {
    print(response.statusCode);
  }
}

class TeamPicker extends StatefulWidget {
  final String apiKey;
  final String eventCode;

  TeamPicker({required this.apiKey, required this.eventCode});

  @override
  _TeamPickerState createState() => _TeamPickerState();
}

class _TeamPickerState extends State<TeamPicker> {
  List<String> teamNames = [];
  List<String> teamCodes = [];

  @override
  void initState() {
    super.initState();
    getData(widget.apiKey, widget.eventCode, (names, codes) {
      setState(() {
        teamNames = names;
        teamCodes = codes;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 19, 81, 179),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        itemCount: teamCodes.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('${teamCodes[index]} - ${teamNames[index]}'),
            onTap: () {
            },
          );
        },
      ),
    );
  }
}