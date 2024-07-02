import 'package:socialseed/domain/entities/user_entity.dart';
import 'package:socialseed/domain/repos/firebase_repository.dart';

class UnFollowUserUsecase {
  final FirebaseRepository repository;

  UnFollowUserUsecase({required this.repository});

  Future<void> call(UserEntity user) async {
    return repository.unfollowUser(user);
  }
}
