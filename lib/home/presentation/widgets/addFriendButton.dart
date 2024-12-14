
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hediety/UserProvider.dart';
import 'package:hediety/home/presentation/widgets/addFriendDialog.dart';
import 'package:provider/provider.dart';

class AddFriendButton extends StatelessWidget {

  final VoidCallback onPressed;

  AddFriendButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final pro = Provider.of<UserProvider>(context);
    return FloatingActionButton(
      onPressed:()=>     showDialog(
      context: context,
      builder: (context) {
        return AddFriendDialog();
      },
    ),
      tooltip: 'Add Friend',
      child: Icon(Icons.person_add),
    );
  }
}
