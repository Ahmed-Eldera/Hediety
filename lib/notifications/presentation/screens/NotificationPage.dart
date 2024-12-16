import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hediety/colors.dart';
import 'package:provider/provider.dart';
import 'package:hediety/UserProvider.dart';

class NotificationPage extends StatefulWidget {
  final String userId; // Data that you want to pass

  NotificationPage({required this.userId});

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Map<String, dynamic>> friendRequests = []; // To store the friend request data
  bool isLoading = true;
  late String userId;

  @override
  void initState() {
    super.initState();
    userId = widget.userId;
    _loadFriendRequests();
  }

  // Function to fetch friend requests from Firestore
  Future<void> _loadFriendRequests() async {
    try {
      // Get the current user's document
      var userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

      if (userDoc.exists) {
        // Get the friendRequests array from the document
        List<dynamic> friendRequestIds = userDoc['friendRequests'] ?? [];

        // If there are friend request IDs, fetch their details
        if (friendRequestIds.isNotEmpty) {
          List<Map<String, dynamic>> requests = [];
          for (var Id in friendRequestIds) {
            // Fetch each friend's details
            var friendDoc = await FirebaseFirestore.instance.collection('users').doc(Id).get();
            if (friendDoc.exists) {
              var friendData = friendDoc.data();
              requests.add({
                'username': friendData?['username'],
                'phone': friendData?['phone'],
                'profilePicture': friendData?['profilePicture'],
                'userId': Id,
              });
            }
          }
          setState(() {
            friendRequests = requests;
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error loading friend requests: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function to accept friend request
  Future<void> acceptFriendRequest({
    required String currentUserId,
    required String targetUserId,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;

      // Reference to both user's documents
      DocumentReference currentUserDocRef = firestore.collection('users').doc(currentUserId);
      DocumentReference targetUserDocRef = firestore.collection('users').doc(targetUserId);

      // Perform a Firestore transaction to safely update the friend request status
      await firestore.runTransaction((transaction) async {
        // Get current and target user documents
        DocumentSnapshot currentUserSnapshot = await transaction.get(currentUserDocRef);
        DocumentSnapshot targetUserSnapshot = await transaction.get(targetUserDocRef);

        if (!currentUserSnapshot.exists || !targetUserSnapshot.exists) {
          throw Exception("User document does not exist.");
        }

        // Get the current friendRequests and friends fields
        List<dynamic>? currentUserFriendRequests = currentUserSnapshot.get('friendRequests') ?? [];
        List<dynamic>? targetUserFriendRequests = targetUserSnapshot.get('friendRequests') ?? [];
        List<dynamic>? currentUserFriends = currentUserSnapshot.get('friends') ?? [];
        List<dynamic>? targetUserFriends = targetUserSnapshot.get('friends') ?? [];

        // Check if the friend request exists in the current user's friendRequests
        if (currentUserFriendRequests!.contains(targetUserId)) {
          // Remove from friendRequests and add to friends for both users
          currentUserFriendRequests.remove(targetUserId);
          targetUserFriendRequests!.remove(currentUserId);

          currentUserFriends!.add(targetUserId);
          targetUserFriends!.add(currentUserId);

          // Update the documents in Firestore
          transaction.update(currentUserDocRef, {
            'friendRequests': currentUserFriendRequests,
            'friends': currentUserFriends,
          });
          transaction.update(targetUserDocRef, {
            'friendRequests': targetUserFriendRequests,
            'friends': targetUserFriends,
          });
          _loadFriendRequests();
        } else {
          throw Exception("Friend request not found.");
        }
      });
    } catch (e) {
      print("Error accepting friend request: $e");
    }
    _loadFriendRequests();
  }

  // Function to decline friend request
  Future<void> declineFriendRequest({
    required String currentUserId,
    required String targetUserId,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;

      // Reference to the current user's document
      DocumentReference currentUserDocRef = firestore.collection('users').doc(currentUserId);

      // Perform a Firestore transaction to safely decline the friend request
      await firestore.runTransaction((transaction) async {
        // Get current user's document
        DocumentSnapshot currentUserSnapshot = await transaction.get(currentUserDocRef);

        if (!currentUserSnapshot.exists) {
          throw Exception("User document does not exist.");
        }

        // Get the current friendRequests field
        List<dynamic>? currentUserFriendRequests = currentUserSnapshot.get('friendRequests') ?? [];

        // Check if the friend request exists
        if (currentUserFriendRequests!.contains(targetUserId)) {
          // Remove the friend request from the current user's friendRequests
          currentUserFriendRequests.remove(targetUserId);

          // Update the current user's document in Firestore
          transaction.update(currentUserDocRef, {
            'friendRequests': currentUserFriendRequests,
          });
          _loadFriendRequests();
        } else {
          throw Exception("Friend request not found.");
        }
      });
    } catch (e) {
      print("Error declining friend request: $e");
    }
    _loadFriendRequests();
  }

  @override
  Widget build(BuildContext context) {
    final pro = Provider.of<UserProvider>(context);
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text('Friend Requests',style: TextStyle(color: gold),),
        backgroundColor: bg,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : friendRequests.isEmpty
              ? Center(child: Text('No friend requests',style: TextStyle(color: Colors.white),))
              : ListView.builder(
                  itemCount: friendRequests.length,
                  itemBuilder: (context, index) {
                    var request = friendRequests[index];
                    return Card(
                      color: lighter,
                      margin: EdgeInsets.all(8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(request['profilePicture'] ?? 'https://via.placeholder.com/150'),
                        ),
                        title: Text(request['username'] ?? 'No name',
                        style: TextStyle(color: a7mar),),
                        subtitle: Text(request['phone'] ?? 'No phone number',style: TextStyle(color: Colors.white),),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.check, color: Colors.green),
                              onPressed: () {
                                acceptFriendRequest(
                                  currentUserId: pro.user!.id, // Current user ID from provider
                                  targetUserId: request['userId'],
                                );
                                _loadFriendRequests(); // Refresh the requests list
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                declineFriendRequest(
                                  currentUserId: pro.user!.id, // Current user ID from provider
                                  targetUserId: request['userId'],
                                );
 // Refresh the requests list
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
