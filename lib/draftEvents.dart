import 'package:flutter/material.dart';
import 'package:hediety/colors.dart';
import 'package:hediety/database_helper.dart';

class ShowSavedEventsPage extends StatefulWidget {
  @override
  _ShowSavedEventsPageState createState() => _ShowSavedEventsPageState();
}

class _ShowSavedEventsPageState extends State<ShowSavedEventsPage> {
  List<Map<String, dynamic>> _savedEvents = [];

  @override
  void initState() {
    super.initState();
    _loadSavedEvents();
  }

  // Load saved events from SQLite
  Future<void> _loadSavedEvents() async {
    List<Map<String, dynamic>> events = await DatabaseHelper.instance.getEvents();
    setState(() {
      _savedEvents = events;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Saved Events',style: TextStyle(backgroundColor: gold),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _savedEvents.isEmpty
            ? Center(child: Text("No saved events"))
            : ListView.builder(
                itemCount: _savedEvents.length,
                itemBuilder: (context, index) {
                  final event = _savedEvents[index];
                  return Card(
                    color: lighter,
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(event['name'], style: TextStyle(color: Colors.white)),
                      subtitle: Text('Date: ${event['date']} | Time: ${event['time']}',
                          style: TextStyle(color: Colors.white)),
                      onTap: () {
                        // You can add a tap handler to view/edit the event details
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}
