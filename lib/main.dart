import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hediety/auth/domain/repositories/auth.dart';
import 'package:provider/provider.dart';
import 'UserProvider.dart';
import 'auth/data/repositories/Login.dart';
import 'auth/data/datasources/firebaseAuth.dart';
import 'auth/presentation/screens/LoginPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final firebaseAuth = FirebaseAuth.instance;
    final FirebaseFirestore firestore=FirebaseFirestore.instance;
    final remoteDataSource = RemoteDataSource(firebaseAuth,firestore);
    final loginRepository = LoginRepository(remoteDataSource);

    runApp(MyApp(loginRepository: loginRepository,remoteDataSource:remoteDataSource));
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
}

class MyApp extends StatelessWidget {
  final LoginRepository loginRepository;
    final RemoteDataSource remoteDataSource;
  const MyApp({required this.loginRepository,required this.remoteDataSource});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserProvider>(
      create: (_) => UserProvider(loginRepository as AuthRepository),
      child: MaterialApp(
        title: 'Flutter App with Clean Architecture',
         theme: ThemeData(
        // primarySwatch: laser,
        fontFamily: "pixel",
      ),
        home: LoginPage(remoteDataSource: remoteDataSource,loginRepository: loginRepository),
      ),
    );
  }
}