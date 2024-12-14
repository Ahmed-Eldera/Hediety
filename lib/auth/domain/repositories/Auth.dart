import "../entities/User.dart";
abstract class AuthRepository{
  Future<MyUser> auth({
   required String email,
   required String password,
   String? phone,
   String? name
   });
}