import 'package:socialseed/domain/entities/story_entity.dart';
import 'package:socialseed/domain/repos/firebase_repository.dart';

class ViewStoryUsecase {
  final FirebaseRepository repository;

  ViewStoryUsecase({required this.repository});

  Future<void> call(StoryEntity story) {
    return repository.viewStory(story);
  }
}
