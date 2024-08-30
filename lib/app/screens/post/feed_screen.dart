import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialseed/app/cubits/post/post_cubit.dart';
import 'package:socialseed/app/cubits/story/story_cubit.dart';
import 'package:socialseed/app/screens/post/post_screen.dart';
import 'package:socialseed/app/screens/post/post_story_screen.dart';
import 'package:socialseed/app/screens/post/story_screen.dart';
import 'package:socialseed/app/widgets/story_card_widget.dart';
import 'package:socialseed/app/widgets/view_post_widget.dart';
import 'package:socialseed/data/models/user_model.dart';
import 'package:socialseed/dependency_injection.dart' as di;
import 'package:socialseed/domain/entities/post_entity.dart';
import 'package:socialseed/domain/entities/story_entity.dart';
import 'package:socialseed/domain/entities/user_entity.dart';
import 'package:socialseed/utils/constants/firebase_const.dart';
import 'package:socialseed/utils/constants/page_const.dart';
import 'package:socialseed/utils/custom/custom_snackbar.dart';

import '../../../utils/constants/color_const.dart';
import '../../../utils/constants/text_const.dart';
import '../friend/search_screen.dart';

class FeedScreen extends StatefulWidget {
  final UserEntity user;

  const FeedScreen({super.key, required this.user});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  void initState() {
    super.initState();
    di.sl<StoryCubit>().fetchStory(uid: widget.user.uid!, context: context);
  }

  Future<UserEntity?> getUserByUid(String uid) async {
    final userCollection =
        FirebaseFirestore.instance.collection(FirebaseConst.users);

    try {
      final DocumentSnapshot doc = await userCollection.doc(uid).get();
      if (doc.exists) {
        return UserModel.fromSnapShot(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider<PostCubit>(
        create: (context) =>
            di.sl<PostCubit>()..getPosts(post: const PostEntity()),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              di.sl<PostCubit>().getPosts(post: const PostEntity());
              di
                  .sl<StoryCubit>()
                  .fetchStory(uid: widget.user.uid!, context: context);
            },
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildSearchBar(context),
                  // _buildStorySection(widget.user),
                  BlocProvider<StoryCubit>(
                    create: (ctx) => di.sl<StoryCubit>()
                      ..fetchStory(uid: widget.user.uid!, context: context),
                    child: BlocBuilder<StoryCubit, StoryState>(
                      builder: (context, state) {
                        if (state is StoryLoaded) {
                          final stories = state.stories
                              .where((story) =>
                                  widget.user.friends!.contains(story.userId) ||
                                  widget.user.uid == story.userId)
                              .toList();

                          return _buildStorySection(stories, widget.user);
                        } else if (state is StoryInitial) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (state is StoryFailure) {
                          return const Center(
                              child: Text('Failed to load stories'));
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  _buildCreatePostSection(context),
                  const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Divider()),
                  _buildPostSection(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.all(12),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: AppColor.greyColor,
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Image.asset(
              'assets/icons/search.png',
              color: AppColor.textGreyColor,
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => SearchScreen(
                    currentUid: widget.user.uid!,
                  ),
                ),
              ),
              child: Text(
                'Search User',
                style: TextConst.MediumStyle(
                  16,
                  AppColor.textGreyColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorySection(List<StoryEntity> stories, UserEntity user) {
    return Container(
      height: 135, // Adjust the height according to your design
      margin: const EdgeInsets.only(bottom: 10.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: stories.length + 1, // +1 for Add Story
        itemBuilder: (context, index) {
          if (index == 0) {
            return Stack(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (ctx) => PostStory(user: user))),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    width: 90, // Adjust the width according to your design
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(user.imageUrl!),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.grey[300],
                    ),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          user.fullname!.split(' ')[0],
                          style: TextConst.MediumStyle(
                            16,
                            AppColor.whiteColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 12,
                  top: 5,
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: AppColor.redColor,
                    ),
                    child: const Icon(
                      Icons.add,
                      color: AppColor.whiteColor,
                    ),
                  ),
                ),
              ],
            );
          } else {
            final story = stories[index - 1];

            return GestureDetector(
              onTap: () async {
                BlocProvider.of<StoryCubit>(context)
                    .viewStory(story: story, context: context);

                final creator = await getUserByUid(story.userId);

                // ignore: use_build_context_synchronously
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (ctx) => StoryScreen(
                          story: story,
                          storyUser: creator!,
                          curruser: user,
                        )));
              },
              child: storyCard(story, user),
            );
          }
        },
      ),
    );
  }

  Widget _buildCreatePostSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => PostScreen(currentUser: widget.user),
            ),
          );
        },
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            border: Border.all(color: AppColor.greyShadowColor),
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage:
                      NetworkImage(widget.user.imageUrl.toString()),
                  radius: 20.0,
                ),
                const SizedBox(width: 10.0),
                const Text(
                  "What's on your mind?",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPostSection(BuildContext context) {
    return BlocBuilder<PostCubit, PostState>(
      builder: (context, state) {
        if (state is PostLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is PostFailure) {
          failureBar(context, "Post Fetching Failed");
        }

        if (state is PostLoaded) {
          return (state.posts.isNotEmpty)
              ? postCardWidget(
                  context, state.posts, widget.user, widget.user.uid.toString())
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.no_photography_sharp),
                    sizeVar(10),
                    const Text('No Post Avaliable')
                  ],
                );
        }

        return const SizedBox();
      },
    );
  }
}
