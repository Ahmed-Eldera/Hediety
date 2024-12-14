import 'package:flutter/material.dart';

class MyError extends StatelessWidget{
  final String message;
  MyError({required this.message, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
      return  AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      }
    
  }

