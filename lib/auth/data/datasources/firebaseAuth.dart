import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hediety/auth/domain/entities/User.dart';
import '../models/User.dart';

class RemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  RemoteDataSource(this.firebaseAuth,this.firestore);

  // Login method using Firebase Auth
  Future<UserModel> login({required String email, required String password}) async {
    try {
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create and return a UserModel
      return UserModel(
        id: userCredential.user?.uid ?? '',
        email: userCredential.user?.email ?? '',
      );
    } catch (error) {
      throw Exception("Login failed: $error");
    }
  }
  Future<UserModel> fetchUserDataFromFirestore(String userId) async {
    try {
      // Get the document snapshot from Firestore
      DocumentSnapshot doc = await firestore.collection('users').doc(userId).get();

      if (doc.exists) {
        // Convert the document data to a UserModel
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // You can add more fields if required
        return UserModel(
          id: userId,
          name: data['username'] ?? '',
          email: data['email'] ?? '',
          phone: data['phone'] ?? '',
        );
      } else {
        throw Exception('User data not found');
      }
    } catch (error) {
      throw Exception('Error fetching user data from Firestore: $error');
    }
  }
    Future<void> insertUserIntoFirestore(MyUser user) async {
    await firestore.collection('users').doc(user.id).set({
            'email': user.email,
            'username': user.name,
            'phone': user.phone,
            'friendRequests':[],
            'friends':[]
            // You can add more user-related data here if needed
          });
     
  }

  // Signup method using Firebase Auth
  Future<UserModel> signup({required String email,required String password, String? name, String? phone}) async {
    try {
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save additional user data (name, phone) in your database if required.
      // Here, we're assuming these details are stored elsewhere, such as Firestore.

      return UserModel(
        id: userCredential.user?.uid ?? '',
        email: userCredential.user?.email ?? '',
        name: name,
        phone: phone,
      );
    } catch (error) {
      throw Exception("Signup failed: $error");
    }
  }
}
