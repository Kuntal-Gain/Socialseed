import 'package:socialseed/domain/entities/story_entity.dart';
import 'package:socialseed/domain/repos/firebase_repository.dart';

class FetchStoryUsecase {
  final FirebaseRepository repository;
  FetchStoryUsecase({required this.repository});
  Stream<List<StoryEntity>> call(String uid) {
    return repository.fetchStories(uid);
  }
}
