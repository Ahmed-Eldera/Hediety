import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hediety/UserProvider.dart';
import 'package:provider/provider.dart';

class AddFriendDialog extends StatefulWidget {
  @override
  _AddFriendDialogState createState() => _AddFriendDialogState();
}

class _AddFriendDialogState extends State<AddFriendDialog> {
  final TextEditingController phoneController = TextEditingController();
  bool isLoading = false;
  Map<String, dynamic>? userData;
  String? friendId;

  // Function to search for a user by phone number
  Future<void> _searchUserByPhone(String phone) async {
    setState(() {
      isLoading = true;
    });

    try {
      // Query Firestore for the user by phone number
      var snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: phone)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // If the user is found, get their data
        setState(() {
          friendId = snapshot.docs.first.id;
          userData = snapshot.docs.first.data();
        });
      } else {
        // If no user is found, reset the userData
        setState(() {
          userData = null;
          friendId = null;
        });
      }
    } catch (e) {
      print("Error searching user: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function to handle adding the friend// Function to handle adding the friend
Future<void> sendFriendRequest({
  required String myUid,
  required String targetUid,
}) async {
  try {
    // Reference to the target user's document
    DocumentReference userDocRef =
        FirebaseFirestore.instance.collection('users').doc(targetUid);

    // Perform a Firestore transaction to safely update the `friendRequests` field
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot userDocSnapshot = await transaction.get(userDocRef);

      if (!userDocSnapshot.exists) {
        throw Exception("Target user document does not exist.");
      }

      // Get the current friendRequests field or initialize an empty list
      List<dynamic>? friendRequests =
          userDocSnapshot.get('friendRequests') ?? [];

      if (friendRequests!.contains(myUid)) {
        // If the UID already exists in the list
        throw Exception("Request already pending.");
      } else {
        // Add the UID to the friendRequests list
        friendRequests.add(myUid);

        // Update the `friendRequests` field in Firestore
        transaction.update(userDocRef, {'friendRequests': friendRequests});
      }
    });
    Navigator.pop(context);
    // Optionally show a success message
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Friend request sent successfully!'),
      backgroundColor: Colors.green,
    ));
  } catch (e, stackTrace) {
        Navigator.pop(context);
    // Print the error and stack trace to the console for debugging
    print("Error sending friend request: $e");
    print("Stack trace: $stackTrace");

    // Handle the error and show a message
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Error: ${e.toString()}'),
      backgroundColor: Colors.red,
    ));
  }
}

  @override
  Widget build(BuildContext context) {
    final pro = Provider.of<UserProvider>(context);

    return AlertDialog(
      title: Text('Add Friend'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: phoneController,
            decoration: InputDecoration(
              labelText: 'Enter Friend\'s Phone Number',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 10),
          isLoading
              ? CircularProgressIndicator()
              : userData == null
                  ? Container()
                  : Column(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(userData!['profilePicture'] ?? 'https://via.placeholder.com/150'),
                        ),
                        SizedBox(height: 10),
                        Text(userData!['username'] ?? 'No username'),
                        SizedBox(height: 10),
                      ],
                    ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Close the dialog
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            if (phoneController.text.isNotEmpty) {
              await _searchUserByPhone(phoneController.text.trim());
            }
          },
          child: Text('Search'),
        ),
        if (userData != null)
          TextButton(
            onPressed: () async {
              if (friendId != null) {
                await sendFriendRequest(
                  myUid: pro.user!.id,
                  targetUid: friendId!,
                );
              }
            },
            child: Text('Add'),
          ),
      ],
    );
  }
}
