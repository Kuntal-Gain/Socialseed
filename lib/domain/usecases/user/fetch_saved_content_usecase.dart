import 'package:socialseed/domain/entities/post_entity.dart';
import 'package:socialseed/domain/repos/firebase_repository.dart';

class FetchSavedContentUsecase {
  final FirebaseRepository repository;
  FetchSavedContentUsecase({required this.repository});

  Stream<List<PostEntity>> call(String uid) {
    return repository.fetchSavedPosts(uid);
  }
}
