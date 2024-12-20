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

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> friends = [];
  List<Map<String, dynamic>> filteredFriends = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  // Function to fetch friends and their events
  Future<void> _loadFriends() async {
    final userId = Provider.of<UserProvider>(context, listen: false).user!.id;

    try {
      var userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        List<dynamic> friendIds = userDoc['friends'] ?? [];

        if (friendIds.isNotEmpty) {
          List<Map<String, dynamic>> fetchedFriends = [];
          for (var friendId in friendIds) {
            var friendDoc = await FirebaseFirestore.instance.collection('users').doc(friendId).get();
            if (friendDoc.exists) {
              var friendData = friendDoc.data()!;
              var events = await _getFriendEvents(friendId);

              fetchedFriends.add({
                'id': friendId,
                'username': friendData['username'],
                'phone': friendData['phone'],
                'pic': friendData['pic'] ?? 'https://via.placeholder.com/150',
                'events': events,
              });
            }
          }

          setState(() {
            friends = fetchedFriends;
            filteredFriends = fetchedFriends;
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
      var eventsSnapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('author', isEqualTo: friendId)
          .get();
      return eventsSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error fetching events for friend: $e');
      return [];
    }
  }

  // Filter friends based on the search query
  void _filterFriends(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredFriends = friends;
      } else {
        filteredFriends = friends
            .where((friend) => friend['username'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
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
             TextField(
              onChanged: _filterFriends,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: lighter,
                hintText: 'Search friends...',
                hintStyle: TextStyle(color: Colors.white54),
                prefixIcon: Icon(Icons.search, color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),SizedBox(height: 20),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: MyButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => EventCreationPage()));
                      },
                      label: 'Create Event',
                      backgroundColor: a7mar,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: MyButton(
                      label: 'Event Drafts',
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ShowSavedEventsPage()));
                      },
                      backgroundColor: gold,
                      textColor: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : filteredFriends.isEmpty
                      ? Center(child: Text('No friends match your search.', style: TextStyle(color: Colors.white)))
                      : RefreshIndicator(
                          onRefresh: _loadFriends,
                          child: ListView.builder(
                            itemCount: filteredFriends.length,
                            itemBuilder: (context, index) {
                              var friend = filteredFriends[index];
                              return FriendListItem(friend: friend);
                            },
                          ),
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
    ImageProvider<Object> img = friend['pic'].contains("https")
        ? NetworkImage(friend['pic'])
        : MemoryImage(imageConverter.stringToImage(friend['pic'])!);
    return Card(
      color: lighter,
      margin: EdgeInsets.all(8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: img,
          radius: 25,
        ),
        title: Text(friend['username'], style: TextStyle(fontSize: 18, color: Colors.white)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                userId: friend['id'],
                isMyEvents: false,
                pic: img,
              ),
            ),
          );
        },
      ),
    );
  }
}
