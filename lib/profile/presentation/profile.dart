import 'package:flutter/material.dart';
import 'package:hediety/UserProvider.dart';
import 'package:hediety/colors.dart';
import 'package:hediety/widgets/MyButton.dart';
import 'package:hediety/widgets/MyTextField.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}



class _ProfilePageState extends State<ProfilePage> {
  String username = '';
  String phoneNumber = '';
  String newPassword = '';
  bool isChanged = false;

  @override
  Widget build(BuildContext context) {
    final pro = Provider.of<UserProvider>(context);
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController usernameController = TextEditingController(text: pro.user!.name);
    final TextEditingController phoneController = TextEditingController(text: pro.user!.phone);

    
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.check, color: Colors.white),
            onPressed: _onSavePressed,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture Section
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/profile_placeholder.png'), // Placeholder image
                    backgroundColor: Colors.grey[300],
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: IconButton(
                      icon: Icon(Icons.camera_alt, color: Colors.white),
                      onPressed: () {
                        print('Change Profile Picture');
                      },
                    ),
                  ),
                ],
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
                MyTextField(controller: usernameController,
                  labelText: 'Username',
                  hintText: 'Enter Your Name',
                ),
                SizedBox(height: 10),
                MyTextField(controller: phoneController,
                  labelText: 'Phone number',
                  hintText: 'Enter Your Number',

                ),
                SizedBox(height: 10),
                MyTextField(controller: passwordController,
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

            // Action Buttons Section (My Events, My Pledged Gifts)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: MyButton(
                    label: 'My Events',
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/myevents');
                    },
                    backgroundColor: a7mar, // Button color
                    textColor: Colors.white,
                  ),
                ),
                SizedBox(width: 10), // Space between the buttons
                Expanded(
                  child: MyButton(
                    label: 'My Pledged Gifts',
                    onPressed: () {
                      print('My Pledged Gifts button pressed');
                    },
                    backgroundColor: gold, // Button color
                    textColor: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onSavePressed() {
    // Implement save functionality here
    print('Profile saved');
  }
}


