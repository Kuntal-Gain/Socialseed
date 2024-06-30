import 'package:socialseed/domain/entities/post_entity.dart';
import 'package:socialseed/domain/repos/firebase_repository.dart';

class FetchPostByUid {
  final FirebaseRepository repository;

  FetchPostByUid({required this.repository});

  Stream<List<PostEntity>> call(String uid) {
    return repository.fetchPostByUid(uid);
  }
}
