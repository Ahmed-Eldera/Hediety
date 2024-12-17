import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hediety/colors.dart';
import 'package:provider/provider.dart'; // To get the current user's ID
import 'package:hediety/UserProvider.dart'; // Assuming this provider has the user info

class GiftDetailsPage extends StatefulWidget {
  final String giftId;

  const GiftDetailsPage({required this.giftId, Key? key}) : super(key: key);

  @override
  _GiftDetailsPageState createState() => _GiftDetailsPageState();
}

class _GiftDetailsPageState extends State<GiftDetailsPage> {
  String status = 'available'; // Initial status of the gift
  String? buyerId;

  @override
  void initState() {
    super.initState();
    _fetchGiftDetails();
  }

  // Fetch gift details to get the initial status and buyer ID
  Future<void> _fetchGiftDetails() async {
    try {
      DocumentSnapshot giftSnapshot = await FirebaseFirestore.instance
          .collection('gifts')
          .doc(widget.giftId)
          .get();

      if (giftSnapshot.exists) {
        var gift = giftSnapshot.data() as Map<String, dynamic>;
        setState(() {
          status = gift['status'] ?? 'available';
          buyerId = gift['buyer'];
        });
      }
    } catch (e) {
      print('Error fetching gift details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final String currentUserId = Provider.of<UserProvider>(context).user!.id;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Gift Details', style: TextStyle(color: gold)),
        backgroundColor: bg,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('gifts').doc(widget.giftId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Gift not found.'));
          }

          var gift = snapshot.data!.data() as Map<String, dynamic>;

          String imageUrl = gift['imageUrl'] ?? 'https://via.placeholder.com/150';
          String name = gift['name'] ?? 'Gift Name';
          String description = gift['description'] ?? 'No description available';
          String price = gift['price'] ?? 'Price not available';

          // Determine the button color based on the status
          Color buttonColor;
          Color fontColor;
          String buttonText;
          if (status == 'pledged') {
            buttonColor = a7mar;
            fontColor=Colors.white;
            buttonText = 'Pledged';
          } else if (status == 'bought') {
            buttonColor = gold;
            
            fontColor=Colors.black;
            buttonText = 'Bought';
          } else {
            buttonColor = Colors.green;
            buttonText = 'Available';
            
            fontColor=Colors.white;
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Display the gift image
                Center(
                  child: Image.network(
                    imageUrl,
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 16),
                // Display the gift name
                Text(
                  name,
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                // Display the gift description
                Text(
                  description,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                // Display the gift price
                Text(
                  'Price: \$${price}',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                SizedBox(height: 24),
                // Display the status button
                ElevatedButton(
                  onPressed: () async {
                    // Show a loading indicator while updating the status
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => Center(child: CircularProgressIndicator()),
                    );

                    try {
                      if (status == 'available') {
                        // If the gift is available, update it to pledged
                        await updateGiftStatus(context, currentUserId, 'pledged', buyerId);
                      } else if (status == 'pledged') {
                        // If the gift is pledged, update it to bought
                        await updateGiftStatus(context, currentUserId, 'bought', buyerId);
                      } else if (status == 'bought') {
                        // If the gift is bought, update it to available
                        await updateGiftStatus(context, currentUserId, 'available', buyerId);
                      }
                    } catch (e) {
                      print('Error updating gift status: $e');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                  ),
                  child: Text(
                    buttonText,
                    style: TextStyle(color: fontColor),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> updateGiftStatus(BuildContext context, String currentUserId, String newStatus, String? buyerId) async {
    try {
      if (newStatus != 'pledged' && (buyerId != null && buyerId != currentUserId)) {
        // Show an error if the gift is pledged by someone else
        Navigator.of(context).pop(); // Close the loading indicator
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Gift Pledged'),
              content: Text('This gift is already pledged by someone else.'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        return;
      }

      // Firestore transaction to update the gift's status
      FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentReference giftRef = FirebaseFirestore.instance.collection('gifts').doc(widget.giftId);
        DocumentSnapshot snapshot = await transaction.get(giftRef);

        if (!snapshot.exists) {
          throw Exception('Gift not found');
        }

        Map<String, dynamic> giftData = snapshot.data() as Map<String, dynamic>;

        // Update the status and buyer ID as needed
        Map<String, dynamic> updatedData = {
          'status': newStatus,
          'buyer':""
        };

        if (newStatus == 'pledged' ||newStatus == 'bought') {
          updatedData['buyer'] = currentUserId;
        } else if (newStatus == 'available' && giftData['buyer'] == currentUserId) {
          updatedData['buyer']="";
        }

        transaction.update(giftRef, updatedData);
      });

      Navigator.of(context).pop(); // Close the loading indicator
      setState(() {
        status = newStatus; // Update the status locally
      });

      print('Gift status updated to $newStatus');
    } catch (e) {
      Navigator.of(context).pop(); // Close the loading indicator
      print('Error updating gift status: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('There was an error updating the gift status.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
}
