import 'package:flutter/material.dart';
import 'package:hediety/auth/data/datasources/firebaseAuth.dart';
import 'package:hediety/UserProvider.dart';
import 'package:hediety/widgets/MyButton.dart';
import 'package:hediety/widgets/MyTextField.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import '../../data/repositories/Signup.dart';

class SignupPage extends StatelessWidget {
  final RemoteDataSource remoteDataSource;
  late final signupRepository = SignupRepository(remoteDataSource);
  SignupPage({required this.remoteDataSource ,super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();

    final pro = Provider.of<UserProvider>(context);
    
    Future<void> _signup(BuildContext context) async {
      try {
        String email = emailController.text.trim();
        String password = passwordController.text.trim();
        String phone = phoneController.text.trim();
        String username = usernameController.text.trim();

        pro.changeProvider(newRepo: signupRepository);

        // Sign up the user with Firebase Authentication
        final userCredential = await pro.signup(email: email, password: password, name: username, phone: phone);

        // Now store the user's data in Firestore
        if (pro.user!.id != null) {
          print("User data stored successfully in Firestore");
          Navigator.pop(context);
        }
      } catch (error) {
        print("Error: $error");
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text(error.toString()),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }

    return Scaffold(
      backgroundColor: Color(0xFF1E173B),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo and title
            Image.asset('assets/pixelGift.png', width: 100, height: 100),
            SizedBox(height: 16),
            Text('Hediety!', style: TextStyle(color: Color.fromARGB(255, 250, 225, 2), fontSize: 40)),
            SizedBox(height: 16),

            // Email Text Field
            MyTextField(controller: emailController, labelText: "Email", hintText: "Enter Your Email"),
            SizedBox(height: 16),
            // Password Text Field
            MyTextField(controller: passwordController, labelText: "Password", hintText: "Enter Your Password", isPassword: true),
            SizedBox(height: 16),
            MyTextField(controller: phoneController, labelText: "Phone number", hintText: "Enter Your Number"),
            SizedBox(height: 16),
            // Username Text Field
            MyTextField(controller: usernameController, labelText: "Username", hintText: "Enter Your Name"),
            SizedBox(height: 16),
            // Sign up Button
            MyButton(label: "Sign up", onPressed: () => _signup(context), backgroundColor: Color.fromARGB(255, 220, 43, 30), textColor: Colors.white),
          ],
        ),
      ),
    );
  }
}
