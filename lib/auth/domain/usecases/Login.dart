import '../../../domain/repositories/auth.dart';
import "../entities/User.dart";
class LoginUseCase {
  final AuthRepository loginRepository;

  LoginUseCase(this.loginRepository);

  Future<MyUser> execute(String email, String password) {
    return loginRepository.auth(email:email, password:password);
  }
}
