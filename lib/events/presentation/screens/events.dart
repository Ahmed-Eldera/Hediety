import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hediety/colors.dart';
import 'package:hediety/events/presentation/screens/eventDetails.dart';

class UserEventsPage extends StatefulWidget {
  final String userId; // User ID to fetch the events
  final bool isMyEvents; // Flag to check if it's the current user's events
  ImageProvider<Object>? pic;
  UserEventsPage({required this.userId, required this.isMyEvents, this.pic});

  @override
  _UserEventsPageState createState() => _UserEventsPageState();
}

class _UserEventsPageState extends State<UserEventsPage> {
  List<Map<String, dynamic>> events = [];
  List<Map<String, dynamic>> filteredEvents = [];
  bool isLoading = true;
  String userName = '';
  String eventNameFilter = '';
  String statusFilter = 'All';
  String categoryFilter = 'All';
  String dateSort = 'Ascending'; // Default sort by ascending date

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  // Fetch events for the given user
  Future<void> _fetchEvents() async {
    try {
      // Fetch user name for display if it's not the current user's events
      if (!widget.isMyEvents) {
        var userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .get();
        if (userDoc.exists) {
          setState(() {
            userName = userDoc['username'] ?? 'Unknown User';
          });
        }
      }

      var eventSnapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('author', isEqualTo: widget.userId) // Fetch events by userId
          .get();

      List<Map<String, dynamic>> fetchedEvents = [];

      for (var doc in eventSnapshot.docs) {
        fetchedEvents.add({
          'id': doc.id,
          ...doc.data(),
        });
      }

      setState(() {
        events = fetchedEvents;
        filteredEvents = fetchedEvents; // Initially show all events
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching events: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Show edit dialog
  void _showEditDialog(Map<String, dynamic> event) {
    final nameController = TextEditingController(text: event['name']);
    final dateController = TextEditingController(text: event['date']);
    final timeController = TextEditingController(text: event['time']);
    final locationController = TextEditingController(text: event['location']);
    final descriptionController = TextEditingController(text: event['description']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Event'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: dateController,
                  decoration: InputDecoration(labelText: 'Date'),
                ),
                TextField(
                  controller: timeController,
                  decoration: InputDecoration(labelText: 'Time'),
                ),
                TextField(
                  controller: locationController,
                  decoration: InputDecoration(labelText: 'Location'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('events')
                      .doc(event['id'])
                      .update({
                    'name': nameController.text,
                    'date': dateController.text,
                    'time': timeController.text,
                    'location': locationController.text,
                    'description': descriptionController.text,
                  });
                  Navigator.pop(context);
                  _fetchEvents(); // Refresh the events
                } catch (e) {
                  print('Error updating event: $e');
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Delete event
  void _deleteEvent(String eventId) async {
    try {
      await FirebaseFirestore.instance.collection('events').doc(eventId).delete();
      _fetchEvents(); // Refresh the events
    } catch (e) {
      print('Error deleting event: $e');
    }
  }

  // Apply the filters and sorting
  void _applyFiltersAndSort() {
    List<Map<String, dynamic>> filtered = List.from(events);

    // Filter by name
    if (eventNameFilter.isNotEmpty) {
      filtered = filtered
          .where((event) => event['name']
              .toString()
              .toLowerCase()
              .contains(eventNameFilter.toLowerCase()))
          .toList();
    }

    // Filter by status (Upcoming/Current/Past)
    if (statusFilter != 'All') {
      DateTime now = DateTime.now();
      filtered = filtered.where((event) {
        DateTime eventDate = DateTime.parse(event['date']);
        if (statusFilter == 'Upcoming') {
          return eventDate.isAfter(now);
        } else if (statusFilter == 'Current') {
          return eventDate.isBefore(now) &&
              eventDate.isAfter(now.subtract(Duration(days: 1)));
        } else {
          // Past
          return eventDate.isBefore(now);
        }
      }).toList();
    }

    // Filter by category
    if (categoryFilter != 'All') {
      filtered = filtered
          .where((event) => event['category'] == categoryFilter)
          .toList();
    }

    // Sort by date
    if (dateSort == 'Ascending') {
      filtered.sort((a, b) => DateTime.parse(a['date'])
          .compareTo(DateTime.parse(b['date'])));
    } else {
      filtered.sort((a, b) => DateTime.parse(b['date'])
          .compareTo(DateTime.parse(a['date'])));
    }

    setState(() {
      filteredEvents = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          widget.isMyEvents ? 'My Events' : '$userName\'s Events',
          style: TextStyle(color: gold),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filter and sorting UI...
                Expanded(
                  child: filteredEvents.isEmpty
                      ? Center(child: Text('No events found.'))
                      : ListView.builder(
                          itemCount: filteredEvents.length,
                          itemBuilder: (context, index) {
                            var event = filteredEvents[index];
                            return Card(
                              color: lighter,
                              child: ListTile(
                                title: Text(
                                  event['name'],
                                  style: TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  'Date: ${event['date']}',
                                  style: TextStyle(color: Colors.white70),
                                ),
                                trailing: widget.isMyEvents
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.edit, color: gold),
                                            onPressed: () =>
                                                _showEditDialog(event),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete,
                                                color: Colors.red),
                                            onPressed: () =>
                                                _deleteEvent(event['id']),
                                          ),
                                        ],
                                      )
                                    : null,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EventDetailPage(
                                        event: event,
                                        pic: widget.pic,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
