import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hediety/colors.dart';
import 'package:hediety/image_handler.dart';
import 'package:hediety/UserProvider.dart';
import 'package:hediety/addGift.dart';
import 'package:hediety/gift/presentation/giftDetailsPage.dart';

class EventDetailPage extends StatefulWidget {
  final Map<String, dynamic> event;
  final ImageProvider<Object>? pic;

  EventDetailPage({required this.event, this.pic, super.key});

  @override
  _EventDetailPageState createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  final ImageConverterr imageConverter = ImageConverterr();

  @override
  Widget build(BuildContext context) {
    final String currentUserId = Provider.of<UserProvider>(context).user!.id;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Event Details', style: TextStyle(color: gold)),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {}); // Refresh UI by triggering a rebuild
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Author's Profile Picture and Name
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: widget.pic,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        widget.event['name'] ?? 'Author Name',
                        style: const TextStyle(color: Colors.white, fontSize: 24),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Event Info
                Text(
                  widget.event['description'] ?? 'Event Name',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  'Date: ${widget.event['date'] ?? 'Date'}',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                Text(
                  'Time: ${widget.event['time'] ?? 'Time'}',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                Text(
                  'Location: ${widget.event['location'] ?? 'Location'}',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.event['description'] ?? 'No description provided',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 24),
                // Add Gift Button (only for event author)
                if (currentUserId == widget.event['author'])
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddGiftPage(eventId: widget.event['id']),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: gold,
                    ),
                    child: const Text(
                      'Add Gift',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                const SizedBox(height: 24),
                // Gifts Section
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('events')
                      .doc(widget.event['id'])
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return const Center(
                        child: Text('Event not found.', style: TextStyle(color: Colors.white)),
                      );
                    }

                    var eventData = snapshot.data!.data() as Map<String, dynamic>;
                    List<String> giftIds = List<String>.from(eventData['gifts'] ?? []);

                    if (giftIds.isEmpty) {
                      return const Center(
                        child: Text('Waiting for gifts...', style: TextStyle(color: Colors.white)),
                      );
                    }

                    // Fetch gifts when available
                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('gifts')
                          .where(FieldPath.documentId, whereIn: giftIds)
                          .snapshots(),
                      builder: (context, giftSnapshot) {
                        if (giftSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (!giftSnapshot.hasData || giftSnapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Text('Waiting for gift data...', style: TextStyle(color: Colors.white)),
                          );
                        }

                        List<Map<String, dynamic>> gifts = giftSnapshot.data!.docs
                            .map((doc) => doc.data() as Map<String, dynamic>)
                            .toList();

                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: gifts.map((gift) {
                            String status = gift['status'] ?? 'Unknown';
                            Color statusColor;

                            // Assign color based on gift status
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => GiftDetailsPage(giftId: gift['id']),
                                  ),
                                );
                              },
                              child: Container(
                                width: (MediaQuery.of(context).size.width - 48) / 2,
                                decoration: BoxDecoration(
                                  color: lighter,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Gift Image
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
                                          ? const Icon(Icons.image, color: Colors.white)
                                          : null,
                                    ),
                                    const SizedBox(height: 8),
                                    // Gift Name and Status
                                    Center(
                                      child: Column(
                                        children: [
                                          Text(
                                            gift['name'] ?? 'Gift ${gifts.indexOf(gift) + 1}',
                                            style: const TextStyle(color: Colors.white, fontSize: 16),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            gift['category'] ?? 'No category',
                                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                                          ),
                                          const SizedBox(height: 4),
                                          // Status
                                          Text(
                                            'Status: $status',
                                            style: TextStyle(
                                              color: statusColor,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
