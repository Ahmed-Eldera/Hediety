import '../../domain/repositories/auth.dart';
import "../entities/User.dart";
class SignupUseCase {
  final AuthRepository signupRepository;

  SignupUseCase(this.signupRepository);

  Future<MyUser> execute(String email, String password, String name, String phone) {
    return signupRepository.auth(email:email, password:password,name:name,phone: phone);
  }
}
