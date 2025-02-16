import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_csv/to_csv.dart' as exportCSV;

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
  final TextEditingController _checkboxes = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();
  final TextEditingController _switchvalue = TextEditingController();
  double _slidervalue = 0.0;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  _loadNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _checkboxes.text = prefs.getString('${widget.teamCode}_${widget.eventCode}_note1') ?? '';
      _controller2.text = prefs.getString('${widget.teamCode}_${widget.eventCode}_note2') ?? '';
      _switchvalue.text = prefs.getString('${widget.teamCode}_${widget.eventCode}_note3') ?? '';
      _slidervalue = double.tryParse(prefs.getString('${widget.teamCode}_${widget.eventCode}_note4') ?? '0.0') ?? 0.0;
    });
  }

  _saveNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('${widget.teamCode}_${widget.eventCode}_note1', _checkboxes.text);
    await prefs.setString('${widget.teamCode}_${widget.eventCode}_note2', _controller2.text);
    await prefs.setString('${widget.teamCode}_${widget.eventCode}_note3', _switchvalue.text);
    await prefs.setString('${widget.teamCode}_${widget.eventCode}_note4', _slidervalue.toString());
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
            Text('Bot Starting Position', style: TextStyle(fontSize: 20)),
            CheckboxListTile(
              title: Text('Left'),
              value: _checkboxes.text.contains('Left'),
              onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                _checkboxes.text += 'Left ';
                } else {
                _checkboxes.text = _checkboxes.text.replaceAll('Left ', '');
                }
              });
              },
            ),
            CheckboxListTile(
              title: Text('Mid'),
              value: _checkboxes.text.contains('Mid'),
              onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                _checkboxes.text += 'Mid ';
                } else {
                _checkboxes.text = _checkboxes.text.replaceAll('Mid ', '');
                }
              });
              },
            ),
            CheckboxListTile(
              title: Text('Right'),
              value: _checkboxes.text.contains('Right'),
              onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                _checkboxes.text += 'Right ';
                } else {
                _checkboxes.text = _checkboxes.text.replaceAll('Right ', '');
                }
              });
              },
            ),
            TextField(
              controller: _controller2,
              decoration: InputDecoration(labelText: 'Auton Rundown'),
              maxLines: null,
              keyboardType: TextInputType.multiline,
            ),
            CheckboxListTile(
              title: Text('Can Score Algae'),
              value: _switchvalue.text.contains('Can Score Algae'),
              onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                _switchvalue.text = 'Can Score Algae ';
                } else {
                _switchvalue.text = '';
                }
              });
              },
            ),
            CheckboxListTile(
              title: Text('Cannot Score Algae'),
              value: _switchvalue.text.contains('Cannot Score Algae'),
              onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                _switchvalue.text = 'Cannot Score Algae ';
                } else {
                _switchvalue.text = '';
                }
              });
              },
            ),
            Text('Coral Level', style: TextStyle(fontSize: 20)),
            Slider(
              value: _slidervalue,
              onChanged: (double value) {
              setState(() {
                _slidervalue = value;
              }); 
              },
              min: 0,
              max: 3,
              divisions: 3,
              label: _slidervalue.round().toString(),
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

  Future<void> makeCSV() async {
    
    List<String> header = [];
    header.add('Team Number');
    header.add('Bot Position');
    header.add('Auton Rundown');
    header.add('Can Score Algae');
    header.add('Coral Level');
    List<List<String>> dataLists = [];
    for (int i = 0; i < teamCodes.length; i++) {
      List<String> data = [];
      data.add(teamCodes[i]);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String botPosition = prefs.getString('${teamCodes[i]}_${widget.eventCode}_note1') ?? '';
      String autonRundown = prefs.getString('${teamCodes[i]}_${widget.eventCode}_note2') ?? '';
      String canScoreAlgae = prefs.getString('${teamCodes[i]}_${widget.eventCode}_note3') ?? '';
      String coralLevel = prefs.getString('${teamCodes[i]}_${widget.eventCode}_note4') ?? '0.0';
      data.add(botPosition);
      data.add(autonRundown);
      data.add(canScoreAlgae);
      data.add(coralLevel);
      dataLists.add(data);
    }
    exportCSV.myCSV(header, dataLists, setHeadersInFirstRow: true, emptyRowsConfig: {1: 1}, fileName: '${widget.eventCode}-');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 19, 81, 179),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: makeCSV,
          ),
        ],
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
