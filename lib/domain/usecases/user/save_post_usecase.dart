import 'package:socialseed/domain/entities/post_entity.dart';
import 'package:socialseed/domain/repos/firebase_repository.dart';

class SavePostUsecase {
  final FirebaseRepository repository;

  SavePostUsecase({required this.repository});

  Future<void> call(PostEntity post) {
    return repository.savePost(post);
  }
}
