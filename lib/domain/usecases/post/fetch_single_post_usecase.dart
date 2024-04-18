import 'package:socialseed/domain/entities/post_entity.dart';
import 'package:socialseed/domain/repos/firebase_repository.dart';

class FetchSinglePostUsecase {
  final FirebaseRepository repository;

  FetchSinglePostUsecase({required this.repository});

  Stream<List<PostEntity>> call(String postId) {
    return repository.fetchSinglePost(postId);
  }
}
