import 'package:flutter/material.dart';
import 'package:hediety/colors.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar at the top with a title and a settings button
      backgroundColor: bg,
      appBar: AppBar(
        title: Text('Welcome Folan'),
        actions: [
          // Settings button in the AppBar
          IconButton(
            icon: Icon(Icons.settings,
            color: Colors.white,),
            
            onPressed: () {
              // Navigate to settings page (to be implemented later)
              print('Settings button pressed');
            },
          ),
        ],
      ),
      // Body content of the home page
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center the button vertically
          crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch the button to full width
          children: [
            // Center the button to create event/list
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16), // Padding to make button taller
                backgroundColor: a7mar
                // textStyle: TextStyle(fontSize: 18), // Font size for button text
              ),
              onPressed: () {
                // Logic for creating event/list (to be added later)
                print('Create Event/List button pressed');
              },
              child: Text('Create Your Own Event/List',
                ),
            ),
            SizedBox(height: 20), // Space between button and list
            // Placeholder for friends list
            Expanded(
              child: Center(
                child: Text(
                  'Friends List will go here...',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      
      ),
      // Floating action button to add friends
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Logic to add friends (to be implemented later)
          print('Add friends button pressed');
        },
        tooltip: 'Add Friend',
        child: Icon(Icons.person_add), // Icon for adding friends
      ),
    );
  }
}
