import "package:hediety/auth/data/models/User.dart";
import "package:hediety/auth/domain/repositories/auth.dart";
import "../../domain/entities/User.dart";
import "../datasources/firebaseAuth.dart";
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class LoginRepository implements AuthRepository {
  final RemoteDataSource remoteDataSource;

  LoginRepository(this.remoteDataSource);

  MyUser toEntity(UserModel? user) {
    return MyUser(
      id: user?.id ?? "",
      name: user?.name ?? "",
      phone: user?.phone??""
    );
  }

  @override
  Future<MyUser> auth({
    required String email,
    required String password,
    String? phone,
    String? name,
  }) async {
    // Perform the login with Firebase Authentication
    final userModel = await remoteDataSource.login(
      email: email,
      password: password,
    );

    // After successful login, fetch additional user data from Firestore
    final userDetails = await remoteDataSource.fetchUserDataFromFirestore(userModel.id);

    // Merge the data from Firestore with the user model
    return toEntity(userDetails);
  }
}
