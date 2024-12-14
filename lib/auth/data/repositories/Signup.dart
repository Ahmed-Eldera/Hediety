import "package:hediety/auth/data/models/User.dart";
import "package:hediety/auth/domain/repositories/Auth.dart";
import "../../domain/entities/User.dart";
import "../datasources/firebaseAuth.dart";
class SignupRepository implements AuthRepository{
  final RemoteDataSource remoteDataSource;

  SignupRepository(this.remoteDataSource);
  MyUser toEntity(UserModel? user) {
    return MyUser(
      id: user?.id??"",
      name: user?.name??"",
      email: user?.email??"",
      phone: user?.phone??""
    );
  }
  @override
  Future<MyUser> auth({
    required String email, 
    required String password,
    String? phone,
    String? name}) 
    async{
        final userModel = await remoteDataSource.signup(
          email: email,
          password: password,
          name: name,
          phone: phone,
        );
        await remoteDataSource.insertUserIntoFirestore(toEntity(userModel));
        return toEntity(userModel);
    }


}