import 'package:flutter/material.dart';
import 'package:hediety/auth/data/repositories/Login.dart';
import 'package:hediety/UserProvider.dart';
import 'package:hediety/widgets/MyButton.dart';
import 'package:hediety/widgets/MyTextField.dart';
import 'package:provider/provider.dart';
import 'SignupPage.dart';
import '../../data/datasources/firebaseAuth.dart';
import '../../../home/presentation/home.dart';

class LoginPage extends StatelessWidget {
    final RemoteDataSource remoteDataSource;
    final LoginRepository loginRepository;
  const LoginPage({required this.remoteDataSource,required this.loginRepository ,super.key});

  @override
  Widget build(BuildContext context) {

    final TextEditingController passwordController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final pro = Provider.of<UserProvider>(context);

    Future<void> _login(BuildContext context) async {
   try {
        String email = emailController.text.trim();
        String password = passwordController.text.trim();
        pro.changeProvider(newRepo:loginRepository);
        await  pro.login(email:email,password: password);
        Navigator.push(
  context, // Current BuildContext
  MaterialPageRoute(builder: (context) => HomePage()), // Define the new page to navigate to
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
            MyTextField(controller: passwordController, labelText: "Password", hintText: "Enter Your Password",isPassword: true),
            SizedBox(height: 16),
            // Login Button

            Row(
              children: [
                Expanded(child: 
                MyButton(label: "Log In", onPressed:()=>_login(context),backgroundColor:Color.fromARGB(255, 220, 43, 30) ,textColor: Colors.white)),
              ],
            ),
            SizedBox(height: 8),
            // Sign Up Button
            Row(
              children: [
                Expanded(
                  child:
                   MyButton(label: "Sign Up",onPressed: () => Navigator.push(context,MaterialPageRoute(builder: (context) => SignupPage(remoteDataSource:remoteDataSource))),
                  backgroundColor:Color.fromARGB(255, 250, 225, 2) ,textColor: Color.fromARGB(255, 0, 0, 0),),
                ),
              ],
            )

          ],
        ),
      ),
    );
  }
}