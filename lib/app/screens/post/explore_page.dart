import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:socialseed/app/cubits/post/post_cubit.dart';
import 'package:socialseed/app/screens/post/video_post_screen.dart';
import 'package:socialseed/app/screens/post/view_post_screen.dart';
import 'package:socialseed/dependency_injection.dart' as di;
import 'package:socialseed/domain/entities/post_entity.dart';
import 'package:socialseed/domain/entities/user_entity.dart';
import 'package:socialseed/utils/constants/color_const.dart';
import 'package:socialseed/utils/constants/text_const.dart';
import 'package:socialseed/utils/custom/custom_snackbar.dart';
import 'package:video_player/video_player.dart';

import '../../../data/models/user_model.dart';
import '../../../features/services/theme_service.dart';
import '../../../utils/constants/firebase_const.dart';

class ExplorePage extends StatefulWidget {
  final UserEntity user;
  const ExplorePage({super.key, required this.user});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  @override
  void initState() {
    super.initState();
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
    final backGroundColor = Provider.of<ThemeService>(context).isDarkMode
        ? AppColor.bgDark
        : AppColor.whiteColor;

    final mq = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: backGroundColor,
      appBar: AppBar(
        backgroundColor: backGroundColor,
        title: Text(
          "Explore",
          style: TextConst.headingStyle(
            25,
            Provider.of<ThemeService>(context).isDarkMode
                ? AppColor.whiteColor
                : AppColor.blackColor,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocProvider(
        create: (context) =>
            di.sl<PostCubit>()..getPosts(post: const PostEntity(), delay: true),
        child: BlocBuilder<PostCubit, PostState>(
          builder: (context, state) {
            if (state is PostFailure) {
              failureBar(context, "Something Went Wrong.");
            }

            if (state is PostLoading) {
              return MasonryGridView.builder(
                gridDelegate:
                    const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // Number of columns
                ),
                itemCount: 30,
                itemBuilder: (context, index) {
                  final isTall = index != 0 &&
                      ((index + 1) % 3 == 0 || (index + 1) % 6 == 0);

                  return Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      margin: const EdgeInsets.all(5),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: !isTall ? 125 : mq.height * 0.275,
                          width: !isTall ? 125 : mq.width / 3,
                          color: AppColor.greyColor.withOpacity(0.3),
                        ),
                      ),
                    ),
                  );
                },
              );
            }

            if (state is PostLoaded) {
              final posts = state.posts;

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: MasonryGridView.builder(
                  gridDelegate:
                      const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // Number of columns
                  ),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final isTall = index != 0 &&
                        ((index + 1) % 3 == 0 || (index + 1) % 6 == 0);

                    final image = posts[index].images![0];
                    final post = posts[index];

                    if (image.contains('.mp4')) {
                      return VideoTileWidget(
                        videoUrl: image,
                        post: post,
                        user: const UserEntity(),
                      );
                    }

                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => PostViewScreen(
                              post: post,
                              user: widget.user,
                              posts: posts,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: !isTall ? 125 : mq.height * 0.275,
                        width: !isTall ? 125 : mq.width / 3,
                        margin: const EdgeInsets.all(5),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: image != null && image.isNotEmpty
                              ? Image.network(
                                  image,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    return loadingProgress == null
                                        ? child
                                        : Center(
                                            child: CupertinoActivityIndicator(
                                              color: AppColor.redColor,
                                            ),
                                          );
                                  },
                                )
                              : Container(
                                  height: 150,
                                  color: AppColor.greyColor.withOpacity(0.3),
                                  child: const Center(
                                    child: Icon(Icons.image_not_supported),
                                  ),
                                ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}

class VideoTileWidget extends StatefulWidget {
  final String videoUrl;
  final PostEntity post;
  final UserEntity user;

  const VideoTileWidget(
      {Key? key,
      required this.videoUrl,
      required this.post,
      required this.user})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _VideoTileWidgetState createState() => _VideoTileWidgetState();
}

class _VideoTileWidgetState extends State<VideoTileWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();

    if (widget.videoUrl.isNotEmpty) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
        ..initialize().then((_) {
          setState(() {
            _isInitialized = true;
          });
        }).catchError((error) {
          if (kDebugMode) {
            print("Video loading error: $error");
          }
        });

      // Stop looping and listen for video end
      _controller.setLooping(false);
      _controller.addListener(() {
        if (_controller.value.position == _controller.value.duration) {
          setState(() {}); // Update UI when video ends
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => VideoPostScreen(
              videoUrl: widget.videoUrl,
              user: widget.user,
              post: widget.post,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(5),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: _isInitialized
              ? Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                    const Positioned.fill(
                      child: Center(
                        child: Icon(
                          Icons.play_arrow,
                          color: AppColor.whiteColor,
                          size: 40,
                        ),
                      ),
                    ),
                    const Positioned.fill(
                      child: Center(
                        child: Icon(
                          Icons.play_circle,
                          color: AppColor.redColor,
                          size: 40,
                        ),
                      ),
                    ),
                  ],
                )
              : Container(
                  height: 150,
                  color: AppColor.greyColor.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
        ),
      ),
    );
  }
}
