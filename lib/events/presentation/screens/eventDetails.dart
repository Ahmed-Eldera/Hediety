import 'package:flutter/material.dart';
import 'package:hediety/addGift.dart';
import 'package:hediety/colors.dart';
import 'package:hediety/image_handler.dart';
import 'package:provider/provider.dart'; // Import Provider for user data
import 'package:hediety/UserProvider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hediety/gift/presentation/giftDetailsPage.dart'; // Import the GiftDetailPage

class EventDetailPage extends StatelessWidget {
  final Map<String, dynamic> event; // Pass the event details as a map
  ImageProvider<Object>? pic;

  EventDetailPage({required this.event, this.pic, super.key});

  @override
  Widget build(BuildContext context) {
    // Access the current user's ID from the Provider
    final String currentUserId = Provider.of<UserProvider>(context).user!.id;
    final ImageConverterr imageConverter = ImageConverterr();

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
                  backgroundImage: pic,
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
            if (currentUserId==event['author'])
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
            // Gifts Wrap (Using StreamBuilder)
            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('events')
                    .doc(event['id'])
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator()); // Show loading indicator
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}')); // Show error message
                  }

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return Center(child: Text('Event not found.', style: TextStyle(color: Colors.white))); // Event not found
                  }

                  // Retrieve the updated event data
                  var eventData = snapshot.data!.data() as Map<String, dynamic>;
                  List<String> updatedGiftIds = List<String>.from(eventData['gifts'] ?? []);

                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('gifts')
                        .where(FieldPath.documentId, whereIn: updatedGiftIds)
                        .snapshots(),
                    builder: (context, giftSnapshot) {
                      if (giftSnapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator()); // Show loading indicator
                      }


                      if (!giftSnapshot.hasData || giftSnapshot.data!.docs.isEmpty||giftSnapshot.hasError) {
                        return Center(child: Text('No gifts available.', style: TextStyle(color: Colors.white))); // No gifts available
                      }

                      List<Map<String, dynamic>> gifts = giftSnapshot.data!.docs
                          .map((doc) => doc.data() as Map<String, dynamic>)
                          .toList();

                      return Wrap(
                        spacing: 8, // Horizontal spacing between items
                        runSpacing: 8, // Vertical spacing between lines
                        children: gifts.map((gift) {
                          String status = gift['status'] ?? 'Unknown';
                          Color statusColor;

                          // Assign color based on the gift status
                          switch (status.toLowerCase()) {
                            case 'available':
                              statusColor = Colors.green;
                              break;
                            case 'pledged':
                              statusColor = Colors.red;
                              break;
                            case 'bought':
                              statusColor = gold;
                              break;
                            default:
                              statusColor = Colors.white70;
                              break;
                          }

                          return GestureDetector(
                            onTap: () {
                              // Navigate to GiftDetailPage and pass the gift data
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GiftDetailsPage(giftId: gift['id']),
                                ),
                              );
                            },
                            child: Container(
                              width: (MediaQuery.of(context).size.width - 48) / 2, // Ensure the container takes up half the width
                              decoration: BoxDecoration(
                                color: lighter,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Limit the image to a fixed square size
                                  Container(
                                    height: 150,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      image: gift['pic'] != null
                                          ? DecorationImage(
                                              image: MemoryImage(imageConverter.stringToImage(gift['pic'])!),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: gift['pic'] == null
                                        ? Icon(Icons.image, color: Colors.white)
                                        : null,
                                  ),
                                  SizedBox(height: 8),
                                  // Gift Name and Status
                                  Center(child: Column(
                                    children: [
                                      Text(
                                        gift['name'] ?? 'Gift ${gifts.indexOf(gift) + 1}',
                                        style: TextStyle(color: Colors.white, fontSize: 16),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        gift['category'] ?? 'No category',
                                        style: TextStyle(color: Colors.white70, fontSize: 12),
                                      ),
                                      SizedBox(height: 4),
                                      // Status with color coding
                                      Text(
                                        'Status: $status',
                                        style: TextStyle(
                                          color: statusColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ))
                                ],
                              ),
                            ),
                          );
                        }).toList(),
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
}
