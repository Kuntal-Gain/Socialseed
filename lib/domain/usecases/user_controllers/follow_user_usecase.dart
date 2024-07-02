import 'package:socialseed/domain/entities/user_entity.dart';
import 'package:socialseed/domain/repos/firebase_repository.dart';

class FollowUserUsecase {
  final FirebaseRepository repository;

  FollowUserUsecase({required this.repository});

  Future<void> call(UserEntity user) async {
    return repository.followUser(user);
  }
}
