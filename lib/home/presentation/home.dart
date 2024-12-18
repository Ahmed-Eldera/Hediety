import 'dart:typed_data';
import 'package:hediety/Image_handler.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hediety/colors.dart';
import 'package:hediety/create_event/presentation/screens/create_event.dart';
import 'package:hediety/draftEvents.dart';
import 'package:hediety/events/presentation/screens/events.dart';
import 'package:hediety/home/presentation/widgets/addFriendButton.dart';
import 'package:hediety/home/presentation/widgets/header.dart';
import 'package:hediety/widgets/MyButton.dart';
import 'package:hediety/UserProvider.dart';
import 'package:provider/provider.dart';

// The HomePage now fetches data from Firestore dynamically
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> friends = [];
  bool isLoading = true;


  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  // Function to fetch friends and their events
  Future<void> _loadFriends() async {
    final userId = Provider.of<UserProvider>(context, listen: false).user!.id;

    try {
      // Fetch the current user's document to get the friend IDs
      var userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        List<dynamic> friendIds = userDoc['friends'] ?? [];

        if (friendIds.isNotEmpty) {
          // Fetch each friend's details and events
          List<Map<String, dynamic>> fetchedFriends = [];
          // List<Map<Uint8List, dynamic>> fetchedFriendspics = [];
          for (var friendId in friendIds) {
            var friendDoc = await FirebaseFirestore.instance.collection('users').doc(friendId).get();
            if (friendDoc.exists) {
              var friendData = friendDoc.data()!;
              var events = await _getFriendEvents(friendId);

              fetchedFriends.add({
                'id': friendId,
                'username': friendData['username'],
                'phone': friendData['phone'],
                'pic': friendData['pic']  ?? 'https://via.placeholder.com/150',
                'events': events,
              });

            }
          }

          setState(() {
            friends = fetchedFriends;
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading friends: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function to fetch events of a friend
  Future<List<Map<String, dynamic>>> _getFriendEvents(String friendId) async {
    try {
      var eventsSnapshot = await FirebaseFirestore.instance.collection('events').where('author', isEqualTo: friendId).get();
      return eventsSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error fetching events for friend: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final pro = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: bg,
      appBar: HeaderWithIcons(name: pro.user!.name),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HeaderWithIcons(name: pro.user!.name),
            SizedBox(height: 20),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                                    Expanded(
                    child:MyButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => EventCreationPage()));
                    },
                    label: 'Create Event',
                    backgroundColor: a7mar,
                  ),),
                  SizedBox(width: 10,),
                   Expanded(
                    child:MyButton(
                      label: 'Event Drafts',
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ShowSavedEventsPage()));
                      },
                      backgroundColor: gold,
                      textColor: Colors.black,
                    ),),

                ],
              ),
            ),
            SizedBox(height: 20),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : friends.isEmpty
                    ? Center(child: Text('You have no friends or they have no events'))
                    : Expanded(
                        child: ListView.builder(
                          itemCount: friends.length,
                          itemBuilder: (context, index) {
                            var friend = friends[index];
                            return FriendListItem(friend: friend);
                          },
                        ),
                      ),
          ],
        ),
      ),
      floatingActionButton: AddFriendButton(
        onPressed: () {
          print('Add friends button pressed');
        },
      ),
    );
  }
}

class FriendListItem extends StatelessWidget {
  final Map<String, dynamic> friend;
  final ImageConverterr imageConverter = ImageConverterr();
  FriendListItem({required this.friend});

  @override
  Widget build(BuildContext context) {
    ImageProvider<Object> img =friend['pic'].contains("https") ? NetworkImage(friend['pic']):MemoryImage(imageConverter.stringToImage(friend['pic'])!);
    return Card(
      color: lighter,
      margin: EdgeInsets.all(8),
      child: ListTile(
        leading: CircleAvatar(

          backgroundImage: img ,
          radius: 25,
        ),

        title: Text(friend['username'], style: TextStyle(fontSize: 18, color: Colors.white)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text('Phone: ${friend['phone']}', style: TextStyle(color: Colors.white)),
            // SizedBox(height: 5),
            Text(
              'Upcoming Events: ${friend['events'].isNotEmpty ? friend['events'].length : 'None'}',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        onTap: () {
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => UserEventsPage(
      userId: friend['id'], // The ID of the user whose events to show
      isMyEvents: false,
      pic:img // Set this to true if it's your own events, false for others
    ),
  ),
);
        },
      ),
    );
  }
}
