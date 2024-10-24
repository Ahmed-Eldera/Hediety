import 'package:flutter/material.dart';
import 'package:hediety/colors.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Aligns items to the left
          children: [
            // Row to display "Welcome Folan" text and settings button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between text and icon
              children: [
                Text(
                  'Welcome Folan',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Row(
                children: [IconButton(
                  icon: Icon(Icons.search, color: Colors.white), // Settings icon
                  onPressed: () {
                    // Navigate to settings page (to be implemented)
                    print('Settings button pressed');
                  },
                ),
                SizedBox(width:10),
                                IconButton(
                  icon: Icon(Icons.settings, color: Colors.white), // Settings icon
                  onPressed: () {
                    // Navigate to settings page (to be implemented)
                    print('Settings button pressed');
                  },
                ),]),
              ],
            ),
            SizedBox(height: 20), // Space between text and button
            // Center the button to create event/list
            Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16,horizontal: 5), // Padding to make button taller
                backgroundColor: a7mar, // Button color
              ),
              onPressed: () {
                print('Create Event/List button pressed');
              },
              child: Text('Create Your Own Event',
              style: TextStyle(color: Colors.white),),
            ),),
            SizedBox(height: 20), // Space between button and list
            // Placeholder for friends list
           Expanded(
  child: ListView.builder(
    itemCount: 10, // Placeholder for 10 friends
    itemBuilder: (context, index) {
      return ListTile(
        leading: CircleAvatar(
          backgroundImage: AssetImage('assets/profile_placeholder.png'), // Placeholder profile picture
          radius: 25,
        ),
        title: Text('Friend #$index', style: TextStyle(fontSize: 18,color: Colors.white)),
        subtitle: Text('Upcoming Events: ${index % 2 == 0 ? '1' : 'None'}'), // Placeholder event status
        trailing: CircleAvatar(
          radius: 10,
          backgroundColor: index % 2 == 0 ? Colors.green : Colors.grey, // Green if events, grey if none
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
      // Floating action button to add friends
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
