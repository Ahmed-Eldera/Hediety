import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hediety/colors.dart';
import 'package:hediety/image_handler.dart';
import 'package:provider/provider.dart';
import 'package:hediety/UserProvider.dart';

class GiftDetailsPage extends StatefulWidget {
  final String giftId;

  const GiftDetailsPage({required this.giftId, Key? key}) : super(key: key);

  @override
  _GiftDetailsPageState createState() => _GiftDetailsPageState();
}

class _GiftDetailsPageState extends State<GiftDetailsPage> {
  
  final ImageConverterr imageConverter = ImageConverterr();

  String status = 'available';
  String? buyerId;

  @override
  void initState() {
    super.initState();
    _fetchGiftDetails();
  }

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

Future<void> _showEditGiftDialog(BuildContext context, Map<String, dynamic> gift) async {
  if (gift['status'] != 'available') {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gift cannot be edited unless it is available')),
    );
    return;
  }

  String updatedName = gift['name'];
  String updatedPrice = gift['price'];
  String updatedDescription = gift['description'];

  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Edit Gift", style: TextStyle(color: gold)),
        backgroundColor: bg,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Name field
            TextField(
              controller: TextEditingController(text: updatedName),
              onChanged: (value) => updatedName = value,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Gift Name",
                labelStyle: TextStyle(color: gold),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: gold),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: gold),
                ),
              ),
            ),
            SizedBox(height: 8),
            // Price field
            TextField(
              controller: TextEditingController(text: updatedPrice),
              onChanged: (value) => updatedPrice = value,
              keyboardType: TextInputType.number,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Price",
                labelStyle: TextStyle(color: gold),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: gold),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: gold),
                ),
              ),
            ),
            SizedBox(height: 8),
            // Description field
            TextField(
              controller: TextEditingController(text: updatedDescription),
              onChanged: (value) => updatedDescription = value,
              maxLines: 3,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Description",
                labelStyle: TextStyle(color: gold),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: gold),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: gold),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Cancel", style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance.collection('gifts').doc(widget.giftId).update({
                  'name': updatedName,
                  'price': updatedPrice,
                  'description': updatedDescription,
                });
                Navigator.of(context).pop(); // Close dialog after saving
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gift updated successfully')),
                );
              } catch (e) {
                print('Error updating gift: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error updating gift')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: gold),
            child: Text("Save", style: TextStyle(color: Colors.black)),
          ),
        ],
      );
    },
  );
}

Future<void> _deleteGift(BuildContext context) async {
  try {
    var giftSnapshot = await FirebaseFirestore.instance.collection('gifts').doc(widget.giftId).get();
    var gift = giftSnapshot.data() as Map<String, dynamic>;

    if (gift['status'] != 'available') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gift cannot be deleted unless it is available')),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('gifts').doc(widget.giftId).delete();
    Navigator.of(context).pop(); // Navigate back after deletion
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gift deleted successfully')));
  } catch (e) {
    print('Error deleting gift: $e');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting gift')));
  }
}

  Future<void> _pledgeBuy(BuildContext context,Map<String, dynamic> gift) async {
    final pro = Provider.of<UserProvider>(context,listen: false).user!.id;
    try {
      if(gift['buyer']==null|| gift['buyer']==pro ||  gift['buyer']==""){
      if(gift['status']=='available')
      {await FirebaseFirestore.instance.collection('gifts').doc(widget.giftId).update({'status':"pledged",'buyer':pro});
      await FirebaseFirestore.instance.collection('users').doc(pro).update({'pledgedGifts':FieldValue.arrayUnion([gift['id']])});
      }else if (gift['status']=='pledged' )
      {await FirebaseFirestore.instance.collection('gifts').doc(widget.giftId).update({'status':"bought"});
      }else if(gift['status']=='bought')
      {await FirebaseFirestore.instance.collection('gifts').doc(widget.giftId).update({'status':"available",'buyer':""});
      await FirebaseFirestore.instance.collection('users').doc(pro).update({'pledgedGifts':FieldValue.arrayRemove([gift['id']])});
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gift updated successfully')));

      }
      else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('you are not the pledger')));
        
      }
    } catch (e) {
      print('Error deleting gift: $e');
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating gift')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final String currentUserId = Provider.of<UserProvider>(context).user!.id;
    final ImageConverterr imageConverter = ImageConverterr();
    final double imageSize = MediaQuery.of(context).size.width * 0.5;

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
          bool isOwner = gift['userId'] == currentUserId;

          String imageUrl = gift['pic'] ?? 'https://via.placeholder.com/150';
          String name = gift['name'] ?? 'Gift Name';
          String description = gift['description'] ?? 'No description available';
          String price = gift['price'] ?? 'Price not available';

          Color buttonColor;
          Color fontColor;
          String buttonText;
          if (status == 'pledged') {
            buttonColor = a7mar;
            fontColor = Colors.white;
            buttonText = 'Pledged';
          } else if (status == 'bought') {
            buttonColor = gold;
            fontColor = Colors.black;
            buttonText = 'Bought';
          } else {
            buttonColor = Colors.green;
            fontColor = Colors.white;
            buttonText = 'Available';
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(),
                GestureDetector(
                  onTap: isOwner ?()=>{}  : null,
                  child: Container(
                    width: imageSize,
                    height: imageSize,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey[800],
                    ),
                    child: gift['pic'] == null
                        ? Image(image: NetworkImage(imageUrl))
                        : Image(image: MemoryImage(imageConverter.stringToImage(gift['pic'])!)),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  name,
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Price: \$${price}',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                SizedBox(height: 24),
                if (isOwner)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () async{
                          var giftData = await FirebaseFirestore.instance.collection('gifts').doc(widget.giftId).get();
                          if (giftData.exists) {
                            await _showEditGiftDialog(context, giftData.data()! as Map<String, dynamic>);
                                  setState(() {
        _fetchGiftDetails();
      });
                        }},
                        style: ElevatedButton.styleFrom(backgroundColor: gold),
                        child: Text("Edit", style: TextStyle(color: Colors.black)),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () => _deleteGift(context),
                        style: ElevatedButton.styleFrom(backgroundColor: a7mar),
                        child: Text("Delete", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                if (!isOwner)
                  ElevatedButton(
                    onPressed: (){
                      _pledgeBuy(context,gift);
                    setState(() {
                      _fetchGiftDetails();
                    });},
                    style: ElevatedButton.styleFrom(backgroundColor: buttonColor),
                    child: Text(buttonText, style: TextStyle(color: fontColor)),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
