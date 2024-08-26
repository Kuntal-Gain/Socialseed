import 'package:socialseed/domain/entities/story_entity.dart';
import 'package:socialseed/domain/repos/firebase_repository.dart';

class AddStoryUsecase {
  final FirebaseRepository repository;

  AddStoryUsecase({required this.repository});
  Future<void> call(StoryEntity story) {
    return repository.addStory(story);
  }
}
