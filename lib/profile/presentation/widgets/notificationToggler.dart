import 'package:flutter/material.dart';

class NotificationSettingsSection extends StatelessWidget {
  const NotificationSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }
}
