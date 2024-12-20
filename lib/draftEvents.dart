import 'package:flutter/material.dart';
import 'package:hediety/colors.dart';
import 'package:hediety/database_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:hediety/UserProvider.dart';
import 'package:uuid/uuid.dart';

class ShowSavedEventsPage extends StatefulWidget {
  @override
  _ShowSavedEventsPageState createState() => _ShowSavedEventsPageState();
}

class _ShowSavedEventsPageState extends State<ShowSavedEventsPage> {
  List<Map<String, dynamic>> _savedEvents = [];
  late String userId;

  @override
  void initState() {
    super.initState();
    userId = Provider.of<UserProvider>(context, listen: false).user!.id;
    _loadSavedEvents();
  }

  // Load saved events from SQLite
  Future<void> _loadSavedEvents() async {
    List<Map<String, dynamic>> events = await DatabaseHelper.instance.getEvents();
    setState(() {
      _savedEvents = events.where((event) => event['author'] == userId).toList();
    });
  }

  // Upload event to Firestore and delete from local DB
  Future<void> _uploadEvent(Map<String, dynamic> event) async {
    try {
      String eventId = event['id'];
      final firestoreEvent = {
        'id': eventId,
        'name': event['name'],
        'author': event['author'],
        'location': event['location'],
        'date': event['date'],
        'time': event['time'],
        'description': event['description'],
        'category': event['category'],
        'gifts': [],
        'coming': [],
      };

      // Upload to Firestore
      await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .set(firestoreEvent);

      // Add the event ID to the user's Firestore document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'events': FieldValue.arrayUnion([eventId])});

      // Delete from local database
      await DatabaseHelper.instance.deleteEvent(eventId);

      // Reload the events
      _loadSavedEvents();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Event uploaded successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload event. Try again.")),
      );
    }
  }

  // Delete event from local DB
  Future<void> _deleteEvent(String eventId) async {
    await DatabaseHelper.instance.deleteEvent(eventId);
    _loadSavedEvents();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Event deleted successfully!")),
    );
  }

  // Edit event (update local DB)
  Future<void> _editEvent(Map<String, dynamic> event) async {
    // Open a dialog for editing
    TextEditingController nameController =
        TextEditingController(text: event['name']);
    TextEditingController locationController =
        TextEditingController(text: event['location']);
    TextEditingController dateController =
        TextEditingController(text: event['date']);
    TextEditingController timeController =
        TextEditingController(text: event['time']);
    TextEditingController descriptionController =
        TextEditingController(text: event['description']);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Event"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: "Event Name"),
                ),
                TextField(
                  controller: locationController,
                  decoration: InputDecoration(labelText: "Location"),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: "Description"),
                ),
                TextField(
                  controller: dateController,
                  decoration: InputDecoration(labelText: "Date"),
                ),
                TextField(
                  controller: timeController,
                  decoration: InputDecoration(labelText: "Time"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await DatabaseHelper.instance.updateEvent({
                  'id': event['id'],
                  'name': nameController.text.trim(),
                  'location': locationController.text.trim(),
                  'date': dateController.text.trim(),
                  'time': timeController.text.trim(),
                  'author': event['author'],
                  'description': event['description'],
                  'category': event['category'],
                });
                Navigator.of(context).pop();
                _loadSavedEvents();
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Saved Events', style: TextStyle(color: gold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _savedEvents.isEmpty
            ? Center(
                child: Text(
                  "No saved events",
                  style: TextStyle(color: Colors.white),
                ),
              )
            : ListView.builder(
                itemCount: _savedEvents.length,
                itemBuilder: (context, index) {
                  final event = _savedEvents[index];
                  return Card(
                    color: lighter,
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(event['name'],
                          style: TextStyle(color: Colors.white)),
                      subtitle: Text(
                        'Date: ${event['date']} | Time: ${event['time']}',
                        style: TextStyle(color: Colors.white),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editEvent(event),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteEvent(event['id']),
                          ),
                          IconButton(
                            icon: Icon(Icons.arrow_upward, color: gold),
                            onPressed: () => _uploadEvent(event),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
