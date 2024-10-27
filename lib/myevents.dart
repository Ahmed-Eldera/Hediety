import 'package:flutter/material.dart';
import 'event.dart';
import 'package:hediety/colors.dart';

class MyEventsPage extends StatefulWidget {
  @override
  _MyEventsPageState createState() => _MyEventsPageState();
}

class _MyEventsPageState extends State<MyEventsPage> {
  List<Map<String, String>> events = [
    {"name": "Event 1", "date": "2024-10-31", "description": "Halloween Party"},
    {"name": "Event 2", "date": "2024-12-25", "description": "Christmas Party"},
  ];

  void _openEventDetail(Map<String, String> event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailPage(
          eventName: event['name']!,
          eventDate: event['date']!,
          eventDescription: event['description']!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text('My Events', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(events[index]["name"]!, style: TextStyle(color: Colors.white)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.white),
                  onPressed: () {
                    // Open edit dialog
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      events.removeAt(index);
                    });
                  },
                ),
              ],
            ),
            onTap: () => _openEventDetail(events[index]),
          );
        },
      ),
    );
  }
}
