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

  // ignore: annotate_overrides
  Widget build(BuildContext context) {
    // Get the screen width and height using MediaQuery
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocProvider<PostCubit>(
        create: (context) =>
            di.sl<PostCubit>()..getPosts(post: const PostEntity()),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              // Fetch posts and stories when the user pulls to refresh
              await Future.wait([
                di.sl<PostCubit>().getPosts(post: const PostEntity()),
                di
                    .sl<StoryCubit>()
                    .fetchStory(uid: widget.user.uid!, context: context),
              ]);
            },
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildSearchBar(context, screenWidth),
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

                          return _buildStorySection(
                              stories, widget.user, screenWidth);
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
                  _buildCreatePostSection(context, screenWidth),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Divider(),
                  ),
                  _buildPostSection(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, double screenWidth) {
    return Container(
      height: 60,
      margin: EdgeInsets.all(screenWidth * 0.03), // Responsive margin
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

  Widget _buildStorySection(
      List<StoryEntity> stories, UserEntity user, double screenWidth) {
    return Container(
      height: 135,
      margin: const EdgeInsets.only(bottom: 10.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: stories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Stack(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (ctx) => PostStory(user: user))),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    width: screenWidth * 0.24, // Responsive width
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

            // Use a FutureBuilder to load the creator asynchronously
            return FutureBuilder<UserEntity?>(
              future: getUserByUid(story.userId), // Fetch the creator by userId
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    width: screenWidth * 0.24,
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    color: Colors.grey[300], // Placeholder while loading
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError || !snapshot.hasData) {
                  return Container(
                    width: screenWidth * 0.24,
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    color: Colors.grey[300], // Placeholder on error
                    child: const Center(
                      child: Icon(Icons.error, color: Colors.red),
                    ),
                  );
                }

                // Creator loaded successfully
                final creator = snapshot.data;

                return GestureDetector(
                  onTap: () {
                    BlocProvider.of<StoryCubit>(context)
                        .viewStory(story: story, context: context);

                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (ctx) => StoryScreen(
                              story: story,
                              storyUser: creator,
                              curruser: user,
                            )));
                  },
                  child: storyCard(
                      story, creator!.fullname!.split(' ')[0], creator),
                );
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildCreatePostSection(BuildContext context, double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.03, vertical: 8), // Responsive padding
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
              ? PostCardWidget(
                  posts: state.posts,
                  user: widget.user,
                  uid: widget.user.uid.toString())
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      sizeVar(100),
                      Image.network(
                        'https://cdn-icons-png.flaticon.com/512/10036/10036774.png',
                        height: 100,
                        width: 100,
                      ),
                      sizeVar(10),
                      Text(
                        'No Post Available',
                        style: TextConst.headingStyle(20, AppColor.blackColor),
                      )
                    ],
                  ),
                );
        }

        return const SizedBox();
      },
    );
  }
}
