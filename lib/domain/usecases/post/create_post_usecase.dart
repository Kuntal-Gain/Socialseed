import 'package:socialseed/domain/entities/post_entity.dart';
import 'package:socialseed/domain/repos/firebase_repository.dart';

class CreatePostUsecase {
  final FirebaseRepository repository;

  CreatePostUsecase({required this.repository});

  Future<void> call(PostEntity post) {
    return repository.createPost(post);
  }
}
