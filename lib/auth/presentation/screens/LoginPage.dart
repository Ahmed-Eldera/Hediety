import 'package:flutter/material.dart';
import 'package:hediety/auth/data/repositories/Login.dart';
import 'package:hediety/UserProvider.dart';
import 'package:hediety/widgets/MyButton.dart';
import 'package:hediety/widgets/MyTextField.dart';
import 'package:provider/provider.dart';
import 'SignupPage.dart';
import '../../data/datasources/firebaseAuth.dart';
import '../../../home/presentation/home.dart';

class LoginPage extends StatefulWidget {
  final RemoteDataSource remoteDataSource;
  final LoginRepository loginRepository;

  const LoginPage({
    required this.remoteDataSource,
    required this.loginRepository,
    super.key,
  });

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late TextEditingController passwordController;
  late TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers here
    passwordController = TextEditingController();
    emailController = TextEditingController();
  }

  @override
  void dispose() {
    // Dispose controllers when the widget is disposed
    passwordController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> _login(BuildContext context) async {
    try {
      String email = emailController.text.trim();
      String password = passwordController.text.trim();
      final pro = Provider.of<UserProvider>(context, listen: false);
      pro.changeProvider(newRepo: widget.loginRepository);
      await pro.login(email: email, password: password);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } catch (error) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E173B),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Use MediaQuery to calculate the center position
              SizedBox(height: MediaQuery.of(context).size.height * 0.2), // Space from the top

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

              // Login Button
              Row(
                children: [
                  Expanded(
                    child: MyButton(
                      label: "Log In",
                      onPressed: () => _login(context),
                      backgroundColor: Color.fromARGB(255, 220, 43, 30),
                      textColor: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),

              // Sign Up Button
              Row(
                children: [
                  Expanded(
                    child: MyButton(
                      label: "Sign Up",
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SignupPage(remoteDataSource: widget.remoteDataSource),
                        ),
                      ),
                      backgroundColor: Color.fromARGB(255, 250, 225, 2),
                      textColor: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.2), // Space at the bottom
            ],
          ),
        ),
      ),
    );
  }
}
