import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hediety/colors.dart';
import 'package:hediety/events/presentation/screens/eventDetails.dart';

class UserEventsPage extends StatefulWidget {
  final String userId;  // User ID to fetch the events
  final bool isMyEvents; // Flag to check if it's the current user's events

  UserEventsPage({required this.userId, required this.isMyEvents});

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
          'name': doc['name'],
          'date': doc['date'],
          'category': doc['category'],
          'description':doc['description'],
          'location':doc['location'],
          'time':doc['time'],
          'author':doc['author'],
          'gifts':doc['gifts']
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
          return eventDate.isBefore(now) && eventDate.isAfter(now.subtract(Duration(days: 1)));
        } else { // Past
          return eventDate.isBefore(now);
        }
      }).toList();
    }

    // Filter by category
    if (categoryFilter != 'All') {
      filtered = filtered.where((event) => event['category'] == categoryFilter).toList();
    }

  if (dateSort == 'Ascending') {
  filtered.sort((a, b) {
    DateTime dateA = DateTime.parse(a['date']); // Parse string into DateTime
    DateTime dateB = DateTime.parse(b['date']); // Parse string into DateTime
    return dateA.compareTo(dateB); // Compare the two DateTime objects
  });
} else {
  filtered.sort((a, b) {
    DateTime dateA = DateTime.parse(a['date']); // Parse string into DateTime
    DateTime dateB = DateTime.parse(b['date']); // Parse string into DateTime
    return dateB.compareTo(dateA); // Compare the two DateTime objects
  });}
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
        title: Text(widget.isMyEvents ? 'My Events' : '$userName\'s Events',style: TextStyle(color:gold ),),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Sort and Filter section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Name filter
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: 'Search by name',
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  eventNameFilter = value;
                                });
                                _applyFiltersAndSort();
                              },
                            ),
                          ),
                          SizedBox(width: 10),
                          // Status filter
                          DropdownButton<String>(
                            value: statusFilter,
                            items: ['All', 'Upcoming', 'Current', 'Past']
                                .map((status) => DropdownMenuItem(
                                      value: status,
                                      child: Text(status),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                statusFilter = value!;
                              });
                              _applyFiltersAndSort();
                            },
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Category filter
                          DropdownButton<String>(
                            value: categoryFilter,
                            items: ['All', 'Personal', 'Work', 'Family']
                                .map((category) => DropdownMenuItem(
                                      value: category,
                                      child: Text(category),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                categoryFilter = value!;
                              });
                              _applyFiltersAndSort();
                            },
                          ),
                          SizedBox(width: 10),
                          // Date sorting
                          DropdownButton<String>(
                            value: dateSort,
                            items: ['Ascending', 'Descending']
                                .map((sort) => DropdownMenuItem(
                                      value: sort,
                                      child: Text(sort),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                dateSort = value!;
                              });
                              _applyFiltersAndSort();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Events List
                Expanded(
                  child: filteredEvents.isEmpty
                      ? Center(child: Text('No events found.'))
                      : ListView.builder(
                          itemCount: filteredEvents.length,
                          itemBuilder: (context, index) {
                            var event = filteredEvents[index];
                            return Card(
                              margin: EdgeInsets.all(8),
                              color: lighter,  // Set the background color of the card
                              child: ListTile(
                                title: Text(
                                  event['name'],
                                  style: TextStyle(fontSize: 18, color: Colors.white),
                                ),
                                subtitle: Text(
                                  'Date: ${ event['date']}',
                                  style: TextStyle(color: Colors.white),
                                ),
                                onTap: () {
                                 Navigator.push(context, MaterialPageRoute(builder: (context)=>EventDetailPage(event: event)));
                                  // Handle event tap here
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
