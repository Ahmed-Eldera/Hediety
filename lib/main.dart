// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hediety/myevents.dart';
import 'package:hediety/profile.dart';
import 'sign_up.dart';
import 'home.dart';

Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); 
  runApp(MyApp());
}
// const MaterialColor laser = MaterialColor(
//   0xFF009EAF, // The primary color
//   <int, Color>{
//     50: Color(0xFFE0F7FA), // 10%
//     100: Color(0xFFB2EBF2), // 20%
//     200: Color(0xFF80DEEA), // 30%
//     300: Color(0xFF4DD0E1), // 40%
//     400: Color(0xFF26C6DA), // 50%
//     500: Color(0xFF009EAF), // 60% (primary color)
//     600: Color(0xFF0094A8), // 70%
//     700: Color(0xFF008C97), // 80%
//     800: Color(0xFF008C8B), // 90%
//     900: Color(0xFF007C79), // 100%
//   },
// );
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Login',
            routes: {
        '/profile': (context) => ProfilePage(), // Define the route for the ProfilePage
        '/home': (context) => HomePage(),
        '/myevents':(context)=>MyEventsPage(), // Define the route for the HomePage
      },
      theme: ThemeData(
        // primarySwatch: laser,
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
            Text('Hediety!',
            style: TextStyle(
              color:Color.fromARGB(255, 250, 225, 2),
              fontSize: 40 ),),
              SizedBox(height: 16),
            // Email Text Field
            TextField(
              controller: _emailController,
              cursorColor: Colors.white,
              decoration: InputDecoration(
                labelStyle: TextStyle(color: Colors.white),
                labelText: 'Email',
                border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: const Color.fromARGB(255, 255, 255, 255), width: 2.0),
                  ),
                                    // Border when the TextField is focused
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 166, 0, 199), width: 2.0), // Change to your desired color
                  ),

              ),
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: Colors.white, fontSize: 18),
              
            ),
            SizedBox(height: 16),

            // Password Text Field
            TextField(
              controller: _passwordController,
              cursorColor: Colors.white,
              decoration: InputDecoration(
                labelStyle: TextStyle(color: Colors.white),
                
                labelText: 'Password',
                border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: const Color.fromARGB(255, 255, 255, 255), width: 2.0),
                  ),
                                  // Border when the TextField is focused
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: const Color.fromARGB(255, 166, 0, 199), width: 2.0), // Change to your desired color
                  ),

              ),
              style: TextStyle(color: Colors.white, fontSize: 18),
              obscureText: true,
              
            ),
            SizedBox(height: 16),

            // Login Button
            ElevatedButton(
              onPressed: () {
                // Navigate to the SignUpPage when the button is pressed
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
              child: Text('Login'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 100, vertical: 16),
                backgroundColor:const Color.fromARGB(255, 220, 43, 30),
                foregroundColor: Colors.white,
              ),
              
            ),
            SizedBox(height: 8),

            // Sign Up Button
            ElevatedButton(
              onPressed: () {
                // Navigate to the SignUpPage when the button is pressed
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpPage()),
                );
              },
              child: Text('Sign Up'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 100, vertical: 16),
                backgroundColor: const Color.fromARGB(255, 250, 225, 2),
                foregroundColor: const Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
