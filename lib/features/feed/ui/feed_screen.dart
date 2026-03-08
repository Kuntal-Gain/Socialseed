import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:socialseed/core/provider/user_provider.dart';
import 'package:socialseed/core/services/route_generator.dart';
import 'package:socialseed/core/utils/constants/color_const.dart';
import 'package:socialseed/core/utils/helpers/app_loader.dart';
import 'package:socialseed/core/utils/helpers/failure_widget.dart';
import 'package:socialseed/core/utils/helpers/screen_utils.dart';
import 'package:socialseed/core/utils/helpers/scroll_view.dart';
import 'package:socialseed/features/auth_module/ui/provider/creds_provider.dart';
import 'package:socialseed/features/feed/ui/widget/post_widget.dart';
import 'package:socialseed/features/feed/ui/widget/story_widget.dart';
import 'package:socialseed/features/post/model/post_model.dart';
import 'package:socialseed/features/post/ui/provider/post_provider.dart';
import 'package:socialseed/features/story/ui/provider/story_provider.dart';
import 'package:socialseed/features/story/ui/story_viewer_screen.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  @override
  Widget build(BuildContext context) {
    final postAsync = ref.watch(feedProvider);

    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      body: CommonScreenWrapper(
        containsScrollable: true,
        body: SafeArea(
          child: Column(
            children: [
              _buildLogo(),
              sizeVer(10),
              _buildSearchbar(),
              sizeVer(10),
              _buildStoryList(),
              postAsync.when(
                data: (posts) {
                  return _buildPostList(posts);
                },
                error: (e, s) => errorWidget(e, s),
                loading: () => AppLoader().stateLoader(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildAddPostFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // widgets

  Widget _buildStoryList() {
    final double cardHeight = ScreenUtils().screenHeight(context) * 0.12;

    final storyAsync = ref.watch(storyNotifierProvider);

    final user = ref.watch(currentUserProvider);

    return storyAsync.when(
        loading: () => AppLoader().stateLoader(),
        error: (e, s) => errorWidget(e, s),
        data: (stories) {
          return SizedBox(
            height: cardHeight + 24, // enough space for +
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: stories.length + 1,
              itemBuilder: (context, index) {
                final story = index > 0 ? stories[index - 1] : null;

                return GestureDetector(
                  onTap: () {
                    if (index == 0) {
                      // Handle add story
                      Navigator.pushNamed(context, RouteGenerator.kStoryUpload);
                    } else {
                      // Navigate to story viewer
                      Navigator.pushNamed(context, RouteGenerator.kStory,
                          arguments: {
                            "story": story,
                          });

                      ref
                          .read(storyNotifierProvider.notifier)
                          .viewStory(story!.creatorUid!);
                    }
                  },
                  child: StoryCard(
                      isAddStory: index == 0,
                      uid: story?.creatorUid ?? user?.uid,
                      isViewed: story?.viewers?.contains(
                              FirebaseAuth.instance.currentUser?.uid) ??
                          false),
                );
              },
            ),
          );
        });
  }

  Widget _buildPostList(List<PostModel> posts) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];

        return PostWidget(post: post, isFeed: true);
      },
    );
  }

  Widget _buildSearchbar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              style: const TextStyle(fontSize: 15),
              decoration: const InputDecoration(
                hintText: "Search users...",
                border: InputBorder.none,
                isCollapsed: true,
              ),
              onChanged: (value) {
                // TODO: Trigger search logic
                // e.g. ref.read(searchProvider.notifier).search(value);
              },
            ),
          ),
          const Icon(Icons.tune_rounded, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Image.asset(
            'assets/images/logo.png',
            height: ScreenUtils().screenHeight(context) * 0.065,
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: IconButton(
            icon: const Icon(
              Ionicons.chatbubble_outline,
              color: AppColor.redColor,
              size: 28,
            ),
            onPressed: () {
              // TODO: Navigate to notifications
              Navigator.of(context).pushNamed(RouteGenerator.kChat);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAddPostFab() {
    return FloatingActionButton.extended(
      backgroundColor: Colors.redAccent,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      onPressed: () {
        // TODO: Navigate to Create Post Screen
        Navigator.of(context).pushNamed(RouteGenerator.kPostCreate);
      },
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text(
        "Add Post",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
