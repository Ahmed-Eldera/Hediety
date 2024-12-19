import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hediety/gift/presentation/giftDetailsPage.dart';
import 'package:provider/provider.dart';
import 'package:hediety/colors.dart';
import 'package:hediety/UserProvider.dart';
import 'package:hediety/image_handler.dart';
// import 'package:hediety/gift/presentation/giftDetailsPage.dart';
class PledgedGiftsPage extends StatefulWidget {
  @override
  _PledgedGiftsPageState createState() => _PledgedGiftsPageState();
}

class _PledgedGiftsPageState extends State<PledgedGiftsPage> {
  final ImageConverterr imageConverter = ImageConverterr();
  String selectedSortOption = 'Date (Newest First)';
  String selectedStatusFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final String currentUserId = Provider.of<UserProvider>(context).user!.id;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: bg,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('My Pledged Gifts', style: TextStyle(color: gold)),
      ),
      backgroundColor: bg,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .snapshots(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (userSnapshot.hasError) {
            return Center(child: Text('Error: ${userSnapshot.error}', style: TextStyle(color: Colors.white)));
          }

          if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
            return Center(child: Text('User data not found.', style: TextStyle(color: Colors.white)));
          }

          var userData = userSnapshot.data!.data() as Map<String, dynamic>;
          List<String> pledgedGiftIds = List<String>.from(userData['pledgedGifts'] ?? []);

          if (pledgedGiftIds.isEmpty) {
            return Center(child: Text('No gifts available.', style: TextStyle(color: Colors.white)));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sort and Filter Section
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    // Sort Dropdown
                    DropdownButton<String>(
                      value: selectedSortOption,
                      icon: Icon(Icons.sort, color: Colors.white),
                      dropdownColor: bg,
                      style: TextStyle(color: Colors.white),
                      items: <String>[
                        'Date (Newest First)',
                        'Date (Oldest First)',
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedSortOption = newValue!;
                        });
                      },
                    ),
                    SizedBox(width: 16),

                    // Status Filter Chips
                    Wrap(
                      spacing: 8,
                      children: ['All', 'Pledged', 'Bought'].map((status) {
                        return ChoiceChip(
                          label: Text(status),
                          selected: selectedStatusFilter == status,
                          onSelected: (selected) {
                            setState(() {
                              selectedStatusFilter = selected ? status : 'All';
                            });
                          },
                          selectedColor: gold,
                          backgroundColor: lighter,
                          labelStyle: TextStyle(color: Colors.white),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              
              // Pledged Gifts List
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('gifts')
                      .where(FieldPath.documentId, whereIn: pledgedGiftIds)
                      .snapshots(),
                  builder: (context, giftSnapshot) {
                    if (giftSnapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (giftSnapshot.hasError) {
                      return Center(child: Text('Error: ${giftSnapshot.error}', style: TextStyle(color: Colors.white)));
                    }

                    var filteredGifts = giftSnapshot.data!.docs
                        .where((doc) {
                          var giftData = doc.data() as Map<String, dynamic>;
                          var status = giftData['status'] ?? '';
                          return selectedStatusFilter == 'All' || status.toLowerCase() == selectedStatusFilter.toLowerCase();
                        })
                        .toList();

                    if (filteredGifts.isEmpty) {
                      return Center(child: Text('No gifts available.', style: TextStyle(color: Colors.white)));
                    }

                    // Sort gifts based on selected sort option
                    filteredGifts.sort((a, b) {
                      var aDate = a['date'] ?? '';
                      var bDate = b['date'] ?? '';
                      if (selectedSortOption == 'Date (Newest First)') {
                        return bDate.compareTo(aDate);
                      }
                      return aDate.compareTo(bDate);
                    });

                    return ListView.builder(
                      itemCount: filteredGifts.length,
                      itemBuilder: (context, index) {
                        var giftData = filteredGifts[index].data() as Map<String, dynamic>;
                        String giftId = filteredGifts[index].id;
                        String eventId = giftData['eventId'] ?? '';
                        String userId = giftData['userId'] ?? '';

                        return FutureBuilder<List<Map<String, String>>>(
                          future: Future.wait([
                            FirebaseFirestore.instance
                                .collection('events')
                                .doc(eventId)
                                .get()
                                .then((doc) => {'eventName': doc['name'] ?? 'Unknown Event', 'eventDate': doc['date'] ?? 'No Date'}),
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(userId)
                                .get()
                                .then((doc) => {'username': doc['username'] ?? 'Unknown User'}),
                          ]),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }
                            if (snapshot.hasError) {
                              return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white)));
                            }

                            var eventData = snapshot.data?[0] ?? {'eventName': 'Unknown Event', 'eventDate': 'No Date'};
                            var userData = snapshot.data?[1] ?? {'username': 'Unknown User'};

                            // Get the status of the gift and assign the color
                            String status = giftData['status'] ?? 'Unknown';
                            Color statusColor;
                            switch (status.toLowerCase()) {
                              case 'pledged':
                                statusColor = a7mar; // Red for pledged
                                break;
                              case 'bought':
                                statusColor = gold; // Gold for bought
                                break;
                              default:
                                statusColor = Colors.white70; // Default color
                                break;
                            }

                            return GestureDetector(
                              onTap: () {
                                // Navigate to GiftDetailsPage with the giftId
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => GiftDetailsPage(giftId: giftId),
                                  ),
                                );
                              },
                              child: Card(
                                color: lighter,
                                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Gift Image
                                      if (giftData['pic'] != null)
                                        Container(
                                          height: 150,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                            image: DecorationImage(
                                              image: MemoryImage(imageConverter.stringToImage(giftData['pic'])!),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      if (giftData['pic'] == null)
                                        Container(
                                          height: 150,
                                          color: Colors.grey,
                                          child: Icon(Icons.image, color: Colors.white, size: 50),
                                        ),
                                      SizedBox(height: 16),
                                      // Gift Name and Status
                                      Text(
                                        giftData['name'] ?? 'Gift ${index + 1}',
                                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Status: $status',
                                        style: TextStyle(color: statusColor, fontSize: 14),
                                      ),
                                      SizedBox(height: 8),
                                      // Event and Recipient Info
                                      Text(
                                        'Event: ${eventData['eventName']}',
                                        style: TextStyle(color: Colors.white, fontSize: 14),
                                      ),
                                      Text(
                                        'Event Date: ${eventData['eventDate']}',
                                        style: TextStyle(color: Colors.white70, fontSize: 12),
                                      ),
                                      Text(
                                        'Recipient: ${userData['username']}',
                                        style: TextStyle(color: Colors.white, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
