import 'package:flutter/material.dart';
import 'package:hediety/colors.dart';

class EventDetailPage extends StatelessWidget {
  final String eventName;
  final String eventDate;
  final String eventDescription;

  EventDetailPage({
    required this.eventName,
    required this.eventDate,
    required this.eventDescription,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(eventName, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date: $eventDate',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            SizedBox(height: 10),
            Text(
              'Description:',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            SizedBox(height: 5),
            Text(
              eventDescription,
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
