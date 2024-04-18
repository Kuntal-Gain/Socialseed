import 'package:socialseed/domain/entities/post_entity.dart';
import 'package:socialseed/domain/repos/firebase_repository.dart';

class DeletePostUsecase {
  final FirebaseRepository repository;

  DeletePostUsecase({required this.repository});

  Future<void> call(PostEntity post) {
    return repository.deletePost(post);
  }
}
