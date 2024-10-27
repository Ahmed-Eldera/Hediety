import 'package:flutter/material.dart';
import 'package:hediety/colors.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Variables to hold the text field values
  String username = '';
  String phoneNumber = '';
  String newPassword = '';

  // To track if there are changes
  bool isChanged = false;

  // Method to show a dialog for current password
  void _showPasswordDialog(BuildContext context) {
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Current Password'),
          content: TextField(
            controller: passwordController,
            decoration: InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Handle password verification here
                // If verified, save the changes
                print('Password entered: ${passwordController.text}');
                Navigator.of(context).pop(); // Close the dialog
                _saveProfile(); // Save the profile after password verification
                Navigator.of(context).pushReplacementNamed('/home'); // Navigate to HomePage
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Method to save the profile
  void _saveProfile() {
    // Implement the saving logic here
    print('Profile saved with Username: $username, Phone: $phoneNumber');
    setState(() {
      // Reset the change flag after saving
    });
  }

  // Method to handle save button press
  void _onSavePressed() {
    if (isChanged) {
      _showPasswordDialog(context); // Show password dialog if there are changes
    } else {
      Navigator.of(context).pushReplacementNamed('/home'); // Navigate to HomePage directly if no changes
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg, // Use the 'bg' background color
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent, // Makes the AppBar blend with the background
        elevation: 0, // Removes shadow
        actions: [
          IconButton(
            icon: Icon(Icons.check, color: Colors.white), // Check icon for save
            onPressed: _onSavePressed, // Call on save button pressed
          ),
        ],
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
              onChanged: (value) {
                setState(() {
                  username = value; // Update username
                  isChanged = true; // Mark as changed
                });
              },
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
              onChanged: (value) {
                setState(() {
                  phoneNumber = value; // Update phone number
                  isChanged = true; // Mark as changed
                });
              },
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
              onChanged: (value) {
                setState(() {
                  newPassword = value; // Update new password
                  isChanged = true; // Mark as changed
                });
              },
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
            SizedBox(height: 10,),
            Row(
  mainAxisAlignment: MainAxisAlignment.spaceAround, // Ensures space is distributed
  children: [
    Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16), // Same padding for both
          backgroundColor: a7mar, // Button color
        ),
              onPressed: () {
                // Handle password verification here
                // If verified, save the changes
                // print('Password entered: ${passwordController.text}');
                // Navigator.of(context).pop(); // Close the dialog
                // _saveProfile(); // Save the profile after password verification
                Navigator.of(context).pushReplacementNamed('/myevents'); // Navigate to HomePage
              },
        child: Text(
          'My Events',
          style: TextStyle(color: Colors.white),
        ),
      ),
    ),
    SizedBox(width: 10),  // Space between the buttons
    Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16), // Same padding for both
          backgroundColor: gold, // Button color
        ),
        onPressed: () {
          print('My Pledged Gifts button pressed');
        },
        child: Text(
          'My Pledged Gifts',
          style: TextStyle(color: Colors.black),
        ),
      ),
    ),
  ],
)

          ],
        ),
      ),
    );
  }
}
