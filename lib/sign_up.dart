import 'package:flutter/material.dart';

// Define the SignUpPage widget
class SignUpPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

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
            // UserName
           TextField(
              controller: _usernameController,
              cursorColor: Colors.white,
              decoration: InputDecoration(
                labelStyle: TextStyle(color: Colors.white),
                labelText: 'UserName',
                border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: const Color.fromARGB(255, 255, 255, 255), width: 2.0),
                  ),
                                    // Border when the TextField is focused
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 166, 0, 199), width: 2.0), // Change to your desired color
                  ),

              ),
              keyboardType: TextInputType.text,
              style: TextStyle(color: Colors.white, fontSize: 18),
              
            ),
            SizedBox(height: 16),
            //phone Number
                       TextField(
              controller: _phoneController,
              cursorColor: Colors.white,
              decoration: InputDecoration(
                labelStyle: TextStyle(color: Colors.white),
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: const Color.fromARGB(255, 255, 255, 255), width: 2.0),
                  ),
                                    // Border when the TextField is focused
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 166, 0, 199), width: 2.0), // Change to your desired color
                  ),

              ),
              keyboardType: TextInputType.number,
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
            // ElevatedButton(
            //   onPressed: (){},
            //   child: Text('Login'),
            //   style: ElevatedButton.styleFrom(
            //     padding: EdgeInsets.symmetric(horizontal: 100, vertical: 16),
            //     backgroundColor:const Color.fromARGB(255, 220, 43, 30),
            //     foregroundColor: Colors.white,
            //   ),
              
            // ),
            // SizedBox(height: 8),

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

