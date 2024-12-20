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
  String selectedCategory = 'All'; // Default category
  String sortBy = 'Date'; // Default sorting option
  String sortOrder = 'Ascending'; // Default sorting order

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

void _deleteEvent(String eventId) async {
  try {
    // Fetch the event document
    var eventDoc = await FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .get();

    if (!eventDoc.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Event does not exist.')),
      );
      return;
    }

    // Get the list of gift IDs
    List<dynamic> giftIds = eventDoc['gifts'] ?? [];

    if (giftIds.isNotEmpty) {
      // Check the status of each gift
      bool allGiftsAvailable = true;

      for (var giftId in giftIds) {
        var giftDoc = await FirebaseFirestore.instance
            .collection('gifts')
            .doc(giftId)
            .get();

        if (giftDoc.exists && giftDoc['status'] != 'available') {
          allGiftsAvailable = false;
          break;
        }
      }

      if (!allGiftsAvailable) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Event cannot be deleted because it has pledged gifts.'),
          ),
        );
        return;
      }
    }

    // Proceed to delete the event
    await FirebaseFirestore.instance.collection('events').doc(eventId).delete();
    _fetchEvents(); // Refresh the events
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Event deleted successfully.')),
    );
  } catch (e) {
    print('Error deleting event: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to delete the event.')),
    );
  }
}

  // Apply the filters and sorting
  void _applyFiltersAndSort() {
    List<Map<String, dynamic>> filtered = List.from(events);

    // Filter by category
    if (selectedCategory != 'All') {
      filtered = filtered
          .where((event) => event['category'] == selectedCategory)
          .toList();
    }

    // Sorting logic
    filtered.sort((a, b) {
      int comparison = 0;
      if (sortBy == 'Date') {
        comparison = DateTime.parse(a['date'])
            .compareTo(DateTime.parse(b['date']));
      } else if (sortBy == 'Name') {
        comparison = a['name'].toString().compareTo(b['name'].toString());
      }
      return sortOrder == 'Ascending' ? comparison : -comparison;
    });

    setState(() {
      filteredEvents = filtered;
      _applyFiltersAndSort();
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
                // Category ChipChoice
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildCategoryChip('All'),
                        _buildCategoryChip('Work'),
                        _buildCategoryChip('Personal'),
                        _buildCategoryChip('Family'),
                      ],
                    ),
                  ),
                ),

                // Sorting UI
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DropdownButton<String>(
                        value: sortBy,
                        dropdownColor: lighter,
                        style: TextStyle(color: Colors.white),
                        items: ['Date', 'Name']
                            .map((option) => DropdownMenuItem(
                                  value: option,
                                  child: Text(option),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              sortBy = value;
                            });
                            _applyFiltersAndSort();
                          }
                        },
                      ),
                      DropdownButton<String>(
                        value: sortOrder,
                        dropdownColor: lighter,
                        style: TextStyle(color: Colors.white),
                        items: ['Ascending', 'Descending']
                            .map((option) => DropdownMenuItem(
                                  value: option,
                                  child: Text(option),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              sortOrder = value;
                            });
                            _applyFiltersAndSort();
                          }
                        },
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

  // Helper method to build category chips
  Widget _buildCategoryChip(String category) {
    bool isSelected = selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Text(
          category,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
        selected: isSelected,
        selectedColor: gold,
        backgroundColor: lighter,
        onSelected: (selected) {
          setState(() {
            selectedCategory = category;
          });
          _applyFiltersAndSort();
        },
      ),
    );
  }
}
