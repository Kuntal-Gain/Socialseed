import 'package:socialseed/domain/entities/user_entity.dart';
import 'package:socialseed/domain/repos/firebase_repository.dart';

class SignInUsecase {
  final FirebaseRepository repository;

  SignInUsecase({required this.repository});

  Future<void> call(UserEntity user) {
    return repository.signInUser(user);
  }
}
