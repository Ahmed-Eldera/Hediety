import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}
const MaterialColor laser = MaterialColor(
  0xFF009EAF, // The primary color
  <int, Color>{
    50: Color(0xFFE0F7FA), // 10%
    100: Color(0xFFB2EBF2), // 20%
    200: Color(0xFF80DEEA), // 30%
    300: Color(0xFF4DD0E1), // 40%
    400: Color(0xFF26C6DA), // 50%
    500: Color(0xFF009EAF), // 60% (primary color)
    600: Color(0xFF0094A8), // 70%
    700: Color(0xFF008C97), // 80%
    800: Color(0xFF008C8B), // 90%
    900: Color(0xFF007C79), // 100%
  },
);
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Login',
      theme: ThemeData(
        primarySwatch: laser,
        fontFamily: "pixel",
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controllers for the text fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // A simple login function (for now just prints the values)
  void _login() {
    String email = _emailController.text;
    String password = _passwordController.text;
    print('Login with Email: $email, Password: $password');
    // Here, you can add your logic for authentication
  }

  // A simple sign-up function (for now just prints the values)
  void _signUp() {
    print('Navigate to Sign-Up Screen');
    // Here, you would typically navigate to another screen for sign-up
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Login'),
      // ),
      backgroundColor: Color(0xFF1E173B),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/pixelGift.png',
                      width: 100,  // Set the desired width
                       height: 100, // Set the desired height
                      ),
            SizedBox(height: 16),
            // Email Text Field
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),

            // Password Text Field
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                
              ),
              obscureText: true,
              
            ),
            SizedBox(height: 16),

            // Login Button
            ElevatedButton(
              onPressed: _login,
              child: Text('Login'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 100, vertical: 16),
              ),
            ),
            SizedBox(height: 8),

            // Sign Up Button
            TextButton(
              onPressed: _signUp,
              child: Text('Sign Up'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 100, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
