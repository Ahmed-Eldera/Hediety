import 'package:flutter/material.dart';
import 'package:hediety/addGift.dart';
import 'package:hediety/colors.dart';
import 'package:provider/provider.dart'; // Import Provider for user data
import 'package:hediety/UserProvider.dart';
class EventDetailPage extends StatelessWidget {
  final Map<String, dynamic> event; // Pass the event details as a map

  const EventDetailPage({required this.event, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Access the current user's ID from the Provider
    final String currentUserId = Provider.of<UserProvider>(context).user!.id;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Event Details', style: TextStyle(color: gold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Author's Profile Picture and Name
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(
                    'https://via.placeholder.com/150', // Replace with actual image URL
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    event['name'] ?? 'Author Name',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            // Event Info
            Text(
              event['description'] ?? 'Event Name',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,

              ),
            ),
            SizedBox(height: 8),
            Text(
              'Date: ${event['date'] ?? 'Date'}',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            Text(
              'Time: ${event['time'] ?? 'time'}',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            Text(
              'Location: ${event['location'] ?? 'Location'}',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              event['description'] ?? 'No description provided',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            SizedBox(height: 24),
            // Conditionally Display Add Gift Button



            // -------------------------------------------LOOK HEERREEE ture condition ------------------------------------------



            
            if (true)
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement gift adding logic
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>AddGiftPage(eventId: event['id'])));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: gold,
                ),
                child: Text(
                  'Add Gift',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            SizedBox(height: 24),
            // Gifts Grid
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: 6, // Stub with 6 items for now
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        'Gift ${index + 1}', // Stub gift name
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
