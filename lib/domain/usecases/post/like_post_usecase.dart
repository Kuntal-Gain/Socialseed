import 'package:socialseed/domain/entities/post_entity.dart';
import 'package:socialseed/domain/repos/firebase_repository.dart';

class LikePostUsecase {
  final FirebaseRepository repository;

  LikePostUsecase({required this.repository});

  Future<void> call(PostEntity post) {
    return repository.likePost(post);
  }
}
