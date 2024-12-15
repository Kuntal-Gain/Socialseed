import 'package:socialseed/domain/repos/firebase_repository.dart';

class IsSignInUsecase {
  final FirebaseRepository repository;

  IsSignInUsecase({required this.repository});

  Future<bool> call() {
    return repository.isSignIn();
  }
}
