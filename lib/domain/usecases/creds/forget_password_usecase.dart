import 'package:socialseed/domain/repos/firebase_repository.dart';

class ForgetPasswordUsecase {
  final FirebaseRepository repository;

  ForgetPasswordUsecase({required this.repository});

  Future<void> call(String email) {
    return repository.forgotPassword(email);
  }
}
