import 'package:flutter/material.dart';
import 'package:hediety/auth/data/datasources/firebaseAuth.dart';
import 'package:hediety/UserProvider.dart';
import 'package:hediety/widgets/MyButton.dart';
import 'package:hediety/widgets/MyTextField.dart';
import 'package:provider/provider.dart';
import '../../data/repositories/Signup.dart';

class SignupPage extends StatefulWidget {
  final RemoteDataSource remoteDataSource;

  SignupPage({required this.remoteDataSource, super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  late final signupRepository = SignupRepository(widget.remoteDataSource);
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final pro = Provider.of<UserProvider>(context);

    Future<void> _signup(BuildContext context) async {
      setState(() {
        isLoading = true;
      });

      try {
        String email = emailController.text.trim();
        String password = passwordController.text.trim();
        String phone = phoneController.text.trim();
        String username = usernameController.text.trim();

        pro.changeProvider(newRepo: signupRepository);

        // Sign up the user with Firebase Authentication
        await pro.signup(
          email: email,
          password: password,
          name: username,
          phone: phone,
        );

        if (pro.user!.id != null) {
          setState(() {
            isLoading = false;
          });

          // Show success Snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Signup successful!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          // Navigate to the previous screen
          Navigator.pop(context);
        }
      } catch (error) {
        setState(() {
          isLoading = false;
        });

        // Show error dialog
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
      body: Stack(
        children: [
          SingleChildScrollView(
            // Makes the entire content scrollable
            child: Container(
              height: MediaQuery.of(context).size.height,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 50), // Space from the top
                    // App logo and title
                    Image.asset('assets/pixelGift.png', width: 100, height: 100),
                    SizedBox(height: 16),
                    Text(
                      'Hediety!',
                      style: TextStyle(
                        color: Color.fromARGB(255, 250, 225, 2),
                        fontSize: 40,
                      ),
                    ),
                    SizedBox(height: 16),

                    // Email Text Field
                    MyTextField(
                      controller: emailController,
                      labelText: "Email",
                      hintText: "Enter Your Email",
                    ),
                    SizedBox(height: 16),

                    // Password Text Field
                    MyTextField(
                      controller: passwordController,
                      labelText: "Password",
                      hintText: "Enter Your Password",
                      isPassword: true,
                    ),
                    SizedBox(height: 16),

                    // Phone Text Field
                    MyTextField(
                      controller: phoneController,
                      labelText: "Phone number",
                      hintText: "Enter Your Number",
                    ),
                    SizedBox(height: 16),

                    // Username Text Field
                    MyTextField(
                      controller: usernameController,
                      labelText: "Username",
                      hintText: "Enter Your Name",
                    ),
                    SizedBox(height: 16),

                    // Sign Up Button
                    MyButton(
                      label: "Sign up",
                      onPressed: () => _signup(context),
                      backgroundColor: Color.fromARGB(255, 220, 43, 30),
                      textColor: Colors.white,
                    ),
                    SizedBox(height: 50), // Space at the bottom
                  ],
                ),
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Color.fromARGB(255, 220, 43, 30)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
