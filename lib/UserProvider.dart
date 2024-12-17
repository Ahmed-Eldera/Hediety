import 'package:flutter/material.dart';
import 'auth/domain/repositories/auth.dart';
import 'auth/domain/entities/User.dart';

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

  void logout() {
    _user = null;
    notifyListeners();
  }
}
