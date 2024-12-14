import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;

  MyButton({
    required this.label,
    required this.onPressed,
    this.backgroundColor = Colors.blue, // Default color
    this.textColor = Colors.white,      // Default text color
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor, // Button background color
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
        ),
      ),
    );
  }
}
