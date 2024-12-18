import 'dart:typed_data';
import 'package:hediety/Image_handler.dart';
import 'package:flutter/material.dart';
import 'package:hediety/UserProvider.dart';
import 'package:hediety/colors.dart';
import 'package:hediety/draftEvents.dart';
import 'package:hediety/events/presentation/screens/events.dart';
import 'package:hediety/widgets/MyButton.dart';
import 'package:hediety/widgets/MyTextField.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
 // Assuming this is in the same directory

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? profilePic; // Base64 string of the profile picture
  bool isChanged = false;

  late TextEditingController usernameController;
  late TextEditingController phoneController;
  late TextEditingController passwordController;
  String? id;
  final ImageConverterr imageConverter = ImageConverterr();

  @override
  void initState() {
    super.initState();
    final pro = Provider.of<UserProvider>(context, listen: false);
    usernameController = TextEditingController(text: pro.user!.name);
    phoneController = TextEditingController(text: pro.user!.phone);
    passwordController = TextEditingController();
    profilePic = pro.user!.pic; 
    id=pro.user!.id;
  }

  Future<void> _pickProfileImage() async {
    String? base64Image = await imageConverter.pickAndCompressImageToString();
    if (base64Image != null) {
      setState(() {
        profilePic = base64Image;
        isChanged = true;
      });
    }
  }

  Future<void> _saveProfileChanges() async {
    final pro = Provider.of<UserProvider>(context, listen: false);
    final userDoc = FirebaseFirestore.instance.collection('users').doc(pro.user!.id);

    // Collect updated fields
    Map<String, dynamic> updates = {};
    if (usernameController.text != pro.user!.name) {
      updates['name'] = usernameController.text;
    }
    if (phoneController.text != pro.user!.phone) {
      updates['phone'] = phoneController.text;
    }
    if (passwordController.text.isNotEmpty) {
      updates['password'] = passwordController.text; // This assumes you store plaintext passwords
    }
    if (profilePic != pro.user!.pic) {
      updates['pic'] = profilePic;
    }

    if (updates.isNotEmpty) {
      // Show a loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Center(child: CircularProgressIndicator()),
      );

      try {
        await userDoc.update(updates);
        pro.updateUser(name: updates['name'],password: updates['password'],phone: updates['phone'],pic: updates['pic']); // Update the provider's user data
        Navigator.pop(context); // Close the loading dialog
        _showConfirmationDialog('Profile updated successfully.');
      } catch (e) {
        Navigator.pop(context); // Close the loading dialog
        _showConfirmationDialog('Error updating profile: $e');
      }
    } else {
      Navigator.pop(context);
    }
  }

  void _showConfirmationDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Update Status'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Uint8List? imageBytes = profilePic != null ? imageConverter.stringToImage(profilePic!) : null;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(color: gold)),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.check, color: Colors.white),
            onPressed: _saveProfileChanges,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture Section
              Center(
                child: GestureDetector(
                  onTap: _pickProfileImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: imageBytes != null
                        ? MemoryImage(imageBytes)
                        : AssetImage('assets/profile_placeholder.png') as ImageProvider,
                    backgroundColor: Colors.grey[300],
                  ),
                ),
              ),
              SizedBox(height: 30),

              // Personal Information Section
              Text(
                'Personal Information',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyTextField(
                    controller: usernameController,
                    labelText: 'Username',
                    hintText: 'Enter Your Name',
                  ),
                  SizedBox(height: 10),
                  MyTextField(
                    controller: phoneController,
                    labelText: 'Phone number',
                    hintText: 'Enter Your Number',
                  ),
                  SizedBox(height: 10),
                  MyTextField(
                    controller: passwordController,
                    labelText: 'New Password',
                    hintText: 'Enter New Password',
                    isPassword: true,
                  ),
                ],
              ),
              SizedBox(height: 30),

              // Notification Settings Section
              Text(
                'Notification Settings',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SwitchListTile(
                title: Text('Receive Notifications', style: TextStyle(color: Colors.white)),
                value: true, // Placeholder value
                onChanged: (bool value) {
                  // Logic for changing notification settings
                },
                activeColor: Colors.white,
                inactiveThumbColor: Colors.grey,
                inactiveTrackColor: Colors.grey,
              ),
              SizedBox(height: 10),

              // Action Buttons Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: MyButton(
                      label: 'My Events',
                      onPressed: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>UserEventsPage(userId: id!, isMyEvents: true,pic: MemoryImage(imageConverter.stringToImage(profilePic!)!) ,)));
                      },
                      backgroundColor: a7mar,
                      textColor: Colors.white,
                    ),
                  ),
                  SizedBox(width: 10),
                 
                 Expanded(
                    child:MyButton(
                      label: 'My Pledged Gifts',
                      onPressed: () {
                        print('My Pledged Gifts button pressed');
                      },
                      backgroundColor: gold,
                      textColor: Colors.black,
                    ),
                                        )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
