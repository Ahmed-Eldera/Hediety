import 'package:flutter/material.dart';

// Define the SignUpPage widget
class SignUpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up Page'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Text(
          'Welcome to the Sign-Up Page!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
