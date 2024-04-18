import 'package:socialseed/domain/entities/post_entity.dart';
import 'package:socialseed/domain/repos/firebase_repository.dart';

class FetchPostUsecase {
  final FirebaseRepository repository;

  FetchPostUsecase({required this.repository});

  Stream<List<PostEntity>> call(PostEntity post) {
    return repository.fetchPost(post);
  }
}
