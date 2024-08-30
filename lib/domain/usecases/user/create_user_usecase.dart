import 'package:socialseed/domain/entities/user_entity.dart';
import 'package:socialseed/domain/repos/firebase_repository.dart';

class CreateUserUsecase {
  final FirebaseRepository repository;

  CreateUserUsecase({required this.repository});

  Future<void> call(UserEntity user) {
    return repository.createUser(user);
  }
}
