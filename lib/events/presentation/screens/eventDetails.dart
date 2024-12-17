import 'package:flutter/material.dart';
import 'package:hediety/addGift.dart';
import 'package:hediety/colors.dart';
import 'package:provider/provider.dart'; // Import Provider for user data
import 'package:hediety/UserProvider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventDetailPage extends StatelessWidget {
  final Map<String, dynamic> event; // Pass the event details as a map

  const EventDetailPage({required this.event, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Access the current user's ID from the Provider
    final String currentUserId = Provider.of<UserProvider>(context).user!.id;

    // Retrieve the 'gifts' field from the event document
    List<String> giftIds = List<String>.from(event['gifts'] ?? []);

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
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Date: ${event['date'] ?? 'Date'}',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            Text(
              'Time: ${event['time'] ?? 'Time'}',
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
            if (true)
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement gift adding logic
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddGiftPage(eventId: event['id']),
                    ),
                  );
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
              child: FutureBuilder<List<Map<String, dynamic>>>( 
                future: fetchGiftsData(giftIds),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator()); // Show loading indicator
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}')); // Show error message
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    print(giftIds);
                    return Center(child: Text('No gifts available.',style: TextStyle(color: Colors.white),)); // No gifts available
                  }

                  List<Map<String, dynamic>> gifts = snapshot.data!;

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: gifts.length,
                    itemBuilder: (context, index) {
                      var gift = gifts[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            // Image.network(
                            // gift['imageUrl'] ?? 'https://via.placeholder.com/150',
                            //   height: 100,
                            //   fit: BoxFit.cover,
                            // ),
                            SizedBox(height: 8),
                            Text(
                              gift['name'] ?? 'Gift ${index + 1}',
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(height: 4),
                            Text(
                              gift['status'] ?? 'Status: Unknown',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fetch the gifts data from Firestore
  Future<List<Map<String, dynamic>>> fetchGiftsData(List<String> giftIds) async {
    List<Map<String, dynamic>> gifts = [];
    for (String giftId in giftIds) {
      try {
        var giftDoc = await FirebaseFirestore.instance.collection('gifts').doc(giftId).get();
        if (giftDoc.exists) {
          gifts.add(giftDoc.data()!);
        }
      } catch (e) {
        print('Error fetching gift data: $e');
      }
    }
    return gifts;
  }
}
