import 'package:flutter/material.dart';
import 'auth/domain/repositories/auth.dart';
import 'auth/domain/entities/User.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class UserProvider with ChangeNotifier {

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

   AuthRepository authRepository;

  MyUser? _user;
  MyUser? get user => _user;

  UserProvider(this.authRepository);
  void changeProvider({required AuthRepository newRepo}){
    this.authRepository=newRepo;
  }

  Future<void> login({required String email,required String password}) async {
    try {
      final user = await authRepository.auth(email: email, password: password);
      _user = user;
      notifyListeners();
    } catch (error) {
      print('3aaa' + error.toString());
      // MyError(message:'$error');
      throw error;
    }
  }
  Future<void> signup({required String email,required String password, required String phone,required String name}) async{
    try{
      final user = await authRepository.auth(email: email,password: password,name: name,phone: phone);
      _user=user;
      notifyListeners();
    }
    catch(error){
      throw error;
    }
  }


Future<void> updateUser({
  String? name,
  String? phone,
  String? password,
  String? pic, // Profile picture
}) async {
  if (_user == null) {
    throw Exception('No user is logged in');
  }

  try {
    // 1. Update Firestore fields (name, phone, pic)
    final updatedFields = {
      if (name != null) 'username': name,
      if (phone != null) 'phone': phone,
      if (pic != null) 'pic': pic,
    };

    if (updatedFields.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.id) // Assuming _user.id is the document ID
          .update(updatedFields);
    }

    // 2. Update password directly via FirebaseAuth
    if (password != null && password.isNotEmpty) {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await currentUser.updatePassword(password);
      } else {
        throw Exception('No authenticated user to update the password');
      }
    }

    // 3. Update the local user object
    _user = _user!.copyWith(
      name: name ?? _user!.name,
      phone: phone ?? _user!.phone,
      pic: pic ?? _user!.pic,
    );

    notifyListeners(); // Notify UI to rebuild
  } catch (error) {
    print('Error updating user: $error');
    throw Exception('Failed to update user: $error');
  }
}

  void logout() {
    _user = null;
    notifyListeners();
  }
}
