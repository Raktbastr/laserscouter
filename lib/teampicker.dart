import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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


class NotesPage extends StatefulWidget {
  final String teamCode;
  final String eventCode;
  final String teamName;
  NotesPage({required this.teamCode, required this.teamName, required this.eventCode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes for $teamName'),
      ),
      body: Center(
        child: Text('Notes for team $teamCode - $teamName'),
      ),
    );
  }
  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();
  final TextEditingController _controller3 = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  _loadNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _controller1.text = prefs.getString('${widget.teamCode}_${widget.eventCode}_note1') ?? '';
      _controller2.text = prefs.getString('${widget.teamCode}_${widget.eventCode}_note2') ?? '';
      _controller3.text = prefs.getString('${widget.teamCode}_${widget.eventCode}_note3') ?? '';
    });
  }

  _saveNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('${widget.teamCode}_${widget.eventCode}_note1', _controller1.text);
    await prefs.setString('${widget.teamCode}_${widget.eventCode}_note2', _controller2.text);
    await prefs.setString('${widget.teamCode}_${widget.eventCode}_note3', _controller3.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes for ${widget.teamName}'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveNotes,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller1,
              decoration: InputDecoration(labelText: 'Note 1'),
            ),
            TextField(
              controller: _controller2,
              decoration: InputDecoration(labelText: 'Note 2'),
            ),
            TextField(
              controller: _controller3,
              decoration: InputDecoration(labelText: 'Note 3'),
            ),
          ],
        ),
      ),
    );
  }
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotesPage(
                    teamName: teamNames[index],
                    eventCode: widget.eventCode,
                    teamCode: teamCodes[index],
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