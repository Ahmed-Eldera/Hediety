import 'package:flutter/material.dart';

class ProfilePictureSection extends StatelessWidget {
  const ProfilePictureSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
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
    );
  }
}
