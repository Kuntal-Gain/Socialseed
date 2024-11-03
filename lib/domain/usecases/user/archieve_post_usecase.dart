import 'package:socialseed/domain/entities/post_entity.dart';
import 'package:socialseed/domain/repos/firebase_repository.dart';

class ArchievePostUsecase {
  final FirebaseRepository repository;

  const ArchievePostUsecase({required this.repository});

  Future<void> call(PostEntity post) {
    return repository.archievePost(post);
  }
}
