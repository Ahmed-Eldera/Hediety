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

  Future<void> _deleteGift(BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('gifts').doc(widget.giftId).delete();
      Navigator.of(context).pop(); // Navigate back after deletion
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gift deleted successfully')));
    } catch (e) {
      print('Error deleting gift: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting gift')));
    }
  }

Future<void> _showEditGiftDialog(BuildContext context, Map<String, dynamic> gift) async {
  String updatedName = gift['name'];
  String updatedPrice = gift['price'];
  String updatedDescription = gift['description'];
  String updatedCategory = gift['category'] ?? 'other'; // Default to 'other'
  String? updatedImage = gift['pic'];
  bool isChanged = false;

  Future<void> _pickProfileImage() async {
    String? base64Image = await imageConverter.pickAndCompressImageToString();
    if (base64Image != null) {
      updatedImage = base64Image;
      isChanged = true;
    }
  }

  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Edit Gift", style: TextStyle(color: gold)),
        backgroundColor: bg,
        content: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Column(
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
                  SizedBox(height: 8),
                  // Category dropdown
                  DropdownButtonFormField<String>(
                    value: updatedCategory,
                    onChanged: (value) => setState(() {
                      updatedCategory = value!;
                    }),
                    dropdownColor: bg,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Category",
                      labelStyle: TextStyle(color: gold),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: gold),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: gold),
                      ),
                    ),
                    items: [
                      "home appliances",
                      "electronics",
                      "fashion",
                      "food",
                      "books",
                      "other"
                    ].map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category, style: TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 16),
                  // Image picker
                  ElevatedButton(
                    onPressed: () async {
                      await _pickProfileImage();
                      setState(() {}); // Refresh dialog to show updated image
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: laser),
                    child: Text("Edit Image", style: TextStyle(color: Colors.white)),
                  ),
                  if (updatedImage != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.memory(
                        imageConverter.stringToImage(updatedImage!)!,
                        height: 100,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // Close dialog without saving
            child: Text("Cancel", style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () async {
              // Save the updated data to Firestore
              try {
                await FirebaseFirestore.instance.collection('gifts').doc(widget.giftId).update({
                  'name': updatedName,
                  'price': updatedPrice,
                  'description': updatedDescription,
                  'category': updatedCategory,
                  if (isChanged) 'pic': updatedImage, // Only update the image if changed
                });
                Navigator.of(context).pop(); // Close dialog after saving
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gift updated successfully')));
              } catch (e) {
                print('Error updating gift: $e');
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating gift')));
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
                            _showEditGiftDialog(context, giftData.data()! as Map<String, dynamic>);
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
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("Action not allowed"),
                            content: Text("You can't pledge or buy your own gift."),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text("OK"),
                              ),
                            ],
                          );
                        },
                      );
                    },
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
