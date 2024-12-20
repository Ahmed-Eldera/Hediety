import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hediety/gift/presentation/giftDetailsPage.dart';
import 'package:provider/provider.dart';
import 'package:hediety/colors.dart';
import 'package:hediety/UserProvider.dart';
import 'package:hediety/image_handler.dart';

class PledgedGiftsPage extends StatefulWidget {
  @override
  _PledgedGiftsPageState createState() => _PledgedGiftsPageState();
}
class _PledgedGiftsPageState extends State<PledgedGiftsPage> {
  final ImageConverterr imageConverter = ImageConverterr();
  String selectedSortOption = 'Date Asc';
  String selectedStatusFilter = 'All';
  List<DocumentSnapshot> allDocs = []; // Holds all gift documents

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

          // Split into chunks if there are more than 10 pledged gifts
          List<List<String>> chunks = splitIntoChunks(pledgedGiftIds, 10);

          return Column(
            children: [
              // Sort and Filter Section
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Wrap(
                      alignment: WrapAlignment.spaceAround,
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
                          selectedColor: status == 'Pledged' ? a7mar : status == "All" ? Colors.blue : gold,
                          backgroundColor: lighter,
                          labelStyle: TextStyle(color: Colors.white),
                        );
                      }).toList(),
                    ),
                    DropdownButton<String>(
                      value: selectedSortOption,
                      icon: Icon(Icons.sort, color: Colors.white),
                      dropdownColor: bg,
                      style: TextStyle(color: Colors.white),
                      items: <String>[
                        'Date Asc',
                        'Date Desc',
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedSortOption = newValue!;
                          // Call the sort function when dropdown value changes
                          sortGifts();
                        });
                      },
                    ),
                  ],
                ),
              ),

              // Pledged Gifts List
              Expanded(
                child: FutureBuilder<List<QuerySnapshot>>(
                  future: Future.wait(chunks.map((chunk) =>
                    FirebaseFirestore.instance
                      .collection('gifts')
                      .where(FieldPath.documentId, whereIn: chunk)
                      .get()
                  ).toList()),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white)));
                    }

                    allDocs = [];
                    for (var chunkSnapshot in snapshot.data!) {
                      allDocs.addAll(chunkSnapshot.docs);
                    }

                    // Filter gifts based on selected status
                    var filteredGifts = allDocs.where((doc) {
                      var giftData = doc.data() as Map<String, dynamic>;
                      var status = giftData['status'] ?? '';
                      return selectedStatusFilter == 'All' || status.toLowerCase() == selectedStatusFilter.toLowerCase();
                    }).toList();

                    if (filteredGifts.isEmpty) {
                      return Center(child: Text('No gifts available.', style: TextStyle(color: Colors.white)));
                    }

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

                            String status = giftData['status'] ?? 'Unknown';
                            Color statusColor;
                            switch (status.toLowerCase()) {
                              case 'pledged':
                                statusColor = a7mar;
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
                                      Text(giftData['name'] ?? 'Gift ${index + 1}',
                                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                      SizedBox(height: 8),
                                      Text('Status: $status', style: TextStyle(color: statusColor, fontSize: 14)),
                                      SizedBox(height: 8),
                                      Text('Event: ${eventData['eventName']}', style: TextStyle(color: Colors.white, fontSize: 14)),
                                      Text('Event Date: ${eventData['eventDate']}', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                      Text('Recipient: ${userData['username']}', style: TextStyle(color: Colors.white, fontSize: 14)),
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

  // Split the list of pledged gifts into chunks of 10
  List<List<String>> splitIntoChunks(List<String> list, int chunkSize) {
    List<List<String>> chunks = [];
    for (int i = 0; i < list.length; i += chunkSize) {
      chunks.add(list.sublist(i, i + chunkSize > list.length ? list.length : i + chunkSize));
    }
    return chunks;
  }

  // Isolated sorting function
  void sortGifts() {
    if (selectedSortOption == 'Date Asc') {
      allDocs.sort((a, b) {
        var aEventId = a['eventId'] ?? '';
        var bEventId = b['eventId'] ?? '';
        var aEventDate = '';
        var bEventDate = '';

        FirebaseFirestore.instance.collection('events').doc(aEventId).get().then((eventDoc) {
          aEventDate = eventDoc['date'] ?? '';
        });

        FirebaseFirestore.instance.collection('events').doc(bEventId).get().then((eventDoc) {
          bEventDate = eventDoc['date'] ?? '';
        });

        return aEventDate.compareTo(bEventDate); // Ascending order
      });
    } else {
      allDocs.sort((a, b) {
        var aEventId = a['eventId'] ?? '';
        var bEventId = b['eventId'] ?? '';
        var aEventDate = '';
        var bEventDate = '';

        FirebaseFirestore.instance.collection('events').doc(aEventId).get().then((eventDoc) {
          aEventDate = eventDoc['date'] ?? '';
        });

        FirebaseFirestore.instance.collection('events').doc(bEventId).get().then((eventDoc) {
          bEventDate = eventDoc['date'] ?? '';
        });

        return bEventDate.compareTo(aEventDate); // Descending order
      });
    }
  }
}
