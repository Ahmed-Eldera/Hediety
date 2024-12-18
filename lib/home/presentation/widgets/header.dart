import 'package:flutter/material.dart';
import 'package:hediety/UserProvider.dart';
import 'package:hediety/profile/presentation/profile.dart';
import 'package:hediety/colors.dart';
import 'package:hediety/notifications/presentation/screens/NotificationPage.dart';
import 'package:provider/provider.dart';

class HeaderWithIcons extends StatelessWidget implements PreferredSizeWidget {
  final String name;
  HeaderWithIcons({this.name = "folan"});

  @override
  Widget build(BuildContext context) {
    final pro = Provider.of<UserProvider>(context);

    return AppBar(
      automaticallyImplyLeading: false, // Removes the back button
      backgroundColor: Colors.transparent, // Keeps it consistent with your background
      elevation: 0, // Removes the shadow
      title: Text(
        'Hi $name',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: gold,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.search, color: Colors.white),
          onPressed: () {
            print('Search button pressed');
          },
        ),
        IconButton(
          icon: Icon(Icons.settings, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.notifications, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NotificationPage(userId: pro.user!.id)),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
