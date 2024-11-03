import 'package:socialseed/domain/entities/post_entity.dart';
import 'package:socialseed/domain/repos/firebase_repository.dart';

class FetchArchievedPosts {
  final FirebaseRepository repository;

  FetchArchievedPosts({required this.repository});

  Stream<List<PostEntity>> call(String uid) {
    return repository.fetchArchievePosts(uid);
  }
}
