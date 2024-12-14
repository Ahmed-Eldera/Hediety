import 'package:flutter/material.dart';
import 'package:hediety/UserProvider.dart';
import 'package:hediety/profile/presentation/profile.dart';
import 'package:hediety/colors.dart';
import 'package:hediety/notifications/presentation/screens/NotificationPage.dart';
import 'package:provider/provider.dart';
class HeaderWithIcons extends StatelessWidget {

  final String name;
  HeaderWithIcons({this.name="folan"});
  @override
  Widget build(BuildContext context) {
        final pro = Provider.of<UserProvider>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Welcome '+name,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: gold,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.search, color: Colors.white),
              onPressed: () {
                print('Search button pressed');
              },
            ),
            SizedBox(width: 10),
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
                  MaterialPageRoute(builder: (context) => NotificationPage(userId:pro.user!.id)),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
