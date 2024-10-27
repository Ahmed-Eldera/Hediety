import 'package:flutter/material.dart';
import 'package:hediety/colors.dart';
import 'package:hediety/profile.dart';

class HomePage extends StatelessWidget {
 void _showCreateEventDialog(BuildContext context) {
  final TextEditingController eventNameController = TextEditingController();
  final TextEditingController eventDateController = TextEditingController();
  final TextEditingController eventDescriptionController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Create New Event'),
        content: Container(
          width: double.maxFinite,  // Allows content to expand horizontally if needed
          height: 250,               // Set a fixed height for the dialog content
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: eventNameController,
                  decoration: InputDecoration(labelText: 'Event Name'),
                ),
                TextField(
                  controller: eventDateController,
                  decoration: InputDecoration(labelText: 'Event Date'),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      eventDateController.text = pickedDate.toString().split(' ')[0];
                    }
                  },
                ),
                TextField(
                  controller: eventDescriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              print('Event saved with details: ${eventNameController.text}, ${eventDateController.text}, ${eventDescriptionController.text}');
            },
            child: Text('Save'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog without saving
            },
            child: Text('Cancel'),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Welcome Folan',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: gold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.search, color: Colors.white),
                      onPressed: () {
                        print('Search button pressed');
                      },
                    ),
                    SizedBox(width: 10),
                    IconButton(
                      icon: Icon(Icons.settings, color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ProfilePage()),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 5),
                  backgroundColor: a7mar,
                ),
                onPressed: () {
                  _showCreateEventDialog(context);
                },
                child: Text(
                  'Create Your Own Event',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage('assets/profile_placeholder.png'),
                      radius: 25,
                    ),
                    title: Text('Friend #$index', style: TextStyle(fontSize: 18, color: Colors.white)),
                    subtitle: Text('Upcoming Events: ${index % 2 == 0 ? '1' : 'None'}'),
                    trailing: CircleAvatar(
                      radius: 10,
                      backgroundColor: index % 2 == 0 ? Colors.green : Colors.grey,
                    ),
                    onTap: () {
                      print('Tapped on Friend #$index');
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('Add friends button pressed');
        },
        tooltip: 'Add Friend',
        child: Icon(Icons.person_add),
      ),
    );
  }
}
