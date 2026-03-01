import 'package:socialseed/features/story/model/story_model.dart';

abstract class StoryUsecase {
  Future<void> createStory(StoryAsset story);
  // Future<void> deleteStory(String segmentId);
  Future<StoryModel> getUserStories(String userId);
  Future<StoryModel> viewStory(String userId);
  Future<List<StoryModel>> getFriendStories(List<String> friendUids);
}
