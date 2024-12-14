import 'package:flutter/material.dart';
import 'package:hediety/colors.dart';
import 'package:hediety/home/presentation/widgets/addFriendButton.dart';
import 'package:hediety/home/presentation/widgets/header.dart';
import 'package:hediety/widgets/MyButton.dart';
import 'package:hediety/UserProvider.dart';
import 'package:provider/provider.dart';
 // Import ProfilePage if necessary

class HomePage extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    final pro = Provider.of<UserProvider>(context);
    return Scaffold(
      backgroundColor: bg,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeaderWithIcons(name: pro.user!.name,), // Replaced with HeaderWithIcons widget
            SizedBox(height: 20),
          
            Center(
              child: MyButton(
                onPressed: () {
                  _showCreateEventDialog(context);
                }, label: 'Create Event',backgroundColor: a7mar,
              ),
            ), // Replaced with CreateEventButton widget
            SizedBox(height: 20),
            // Friend list (not yet separated)
            Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  return FriendListItem(index: index); // This is to be done later
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: AddFriendButton(
        onPressed: () {
          print('Add friends button pressed');
        },
      ), // Replaced with AddFriendButton widget
    );
  }

  void _showCreateEventDialog(BuildContext context) {
    // Implement the dialog logic for creating an event
  }
}
class FriendListItem extends StatelessWidget {
  final int index;

  FriendListItem({required this.index});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: AssetImage('assets/profile_placeholder.png'),
        radius: 25,
      ),
      title: Text('Friend #$index', style: TextStyle(fontSize: 18, color: Colors.white)),
      subtitle: Text('Upcoming Events: ${index % 2 == 0 ? '1' : 'None'}'),
      trailing: CircleAvatar(
        radius: 10,
        backgroundColor: index % 2 == 0 ? Colors.green : Colors.grey,
      ),
      onTap: () {
        print('Tapped on Friend #$index');
      },
    );
  }
}