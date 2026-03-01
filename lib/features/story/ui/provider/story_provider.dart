import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socialseed/features/auth_module/ui/provider/creds_provider.dart';
import 'package:socialseed/features/story/data/story_usecase.dart';
import 'package:socialseed/features/story/data/story_usecase_impl.dart';
import 'package:socialseed/features/story/model/story_model.dart';

/// Provider
final storyNotifierProvider =
    AutoDisposeAsyncNotifierProvider<StoryNotifier, List<StoryModel>>(
        StoryNotifier.new);

class StoryNotifier extends AutoDisposeAsyncNotifier<List<StoryModel>> {
  /// Called when provider is first created
  @override
  Future<List<StoryModel>> build() async {
    final _storyUsecase = StoryUsecaseImpl();

    final user = ref.watch(currentUserProvider);

    // initial empty state
    return loadFriendStories(user?.following ?? []);
  }

  /// ─────────────────────────────────────────────
  /// Load Friend Stories (Today Only)
  /// ─────────────────────────────────────────────
  Future<List<StoryModel>> loadFriendStories(List<String> friendUids) async {
    final _storyUsecase = StoryUsecaseImpl();
    final stories = await _storyUsecase.getFriendStories(friendUids);

    // Optional: sort by latest update
    stories.sort(
      (a, b) => b.updatedAt!.compareTo(a.updatedAt!),
    );

    return stories;
  }

  /// ─────────────────────────────────────────────
  /// Load Single User Story
  /// ─────────────────────────────────────────────
  Future<StoryModel?> loadUserStory(String userId) async {
    final _storyUsecase = StoryUsecaseImpl();
    try {
      return await _storyUsecase.getUserStories(userId);
    } catch (_) {
      return null; // no story today
    }
  }

  /// ─────────────────────────────────────────────
  /// Create Story (append segment)
  /// ─────────────────────────────────────────────
  Future<void> createStory(StoryAsset asset) async {
    final _storyUsecase = StoryUsecaseImpl();

    await _storyUsecase.createStory(asset);

    // Optional:
    // You can refresh current user story here if needed
  }

  /// ─────────────────────────────────────────────
  /// View Story
  /// Adds current user to viewers
  /// Optimistically updates UI
  /// ─────────────────────────────────────────────
  Future<void> viewStory(String userId) async {
    final _storyUsecase = StoryUsecaseImpl();

    await _storyUsecase.viewStory(userId);

    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    // Optimistic UI update
    state = state.whenData((stories) {
      return stories.map((story) {
        if (story.creatorUid == userId &&
            story.viewers != null &&
            !story.viewers!.contains(currentUid)) {
          return story.copyWith(
            viewers: [...story.viewers!, currentUid!],
          );
        }
        return story;
      }).toList();
    });
  }
}
