import 'package:flutter/material.dart';
import 'package:hediety/colors.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg, // Use the 'bg' background color
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent, // Makes the AppBar blend with the background
        elevation: 0, // Removes shadow
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                        // Logic for updating profile picture (e.g., open image picker)
                        print('Change Profile Picture');
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            Text(
              'Personal Information',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 10),
            // Placeholder for name, email, and other fields
            TextField(
              decoration: InputDecoration(
                labelText: 'Username',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: 'Phone number',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
                        SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: 'New Password',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 30),
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
            // SwitchListTile(
            //   title: Text('Receive Email Updates', style: TextStyle(color: Colors.white)),
            //   value: false, // Placeholder value
            //   onChanged: (bool value) {
            //     // Logic for changing email settings
            //   },
            //   activeColor: Colors.white,
            //   inactiveThumbColor: Colors.grey,
            //   inactiveTrackColor: Colors.grey,
            // ),
          ],
        ),
      ),
    );
  }
}
