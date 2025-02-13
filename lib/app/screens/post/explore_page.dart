import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:socialseed/app/cubits/post/post_cubit.dart';
import 'package:socialseed/app/screens/post/view_post_screen.dart';
import 'package:socialseed/dependency_injection.dart' as di;
import 'package:socialseed/domain/entities/post_entity.dart';
import 'package:socialseed/domain/entities/user_entity.dart';
import 'package:socialseed/utils/constants/color_const.dart';
import 'package:socialseed/utils/constants/text_const.dart';
import 'package:socialseed/utils/custom/custom_snackbar.dart';
import 'package:video_player/video_player.dart';

import '../../../data/models/user_model.dart';
import '../../../utils/constants/firebase_const.dart';

class ExplorePage extends StatefulWidget {
  final UserEntity user;
  const ExplorePage({super.key, required this.user});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

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
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColor.whiteColor,
        title: Text(
          "Explore",
          style: TextConst.headingStyle(25, AppColor.blackColor),
        ),
        centerTitle: true,
      ),
      body: BlocProvider(
        create: (context) => di.sl<PostCubit>()..getPosts(post: PostEntity()),
        child: BlocBuilder<PostCubit, PostState>(
          builder: (context, state) {
            if (state is PostFailure) {
              failureBar(context, "Something Went Wrong.");
            }
            if (state is PostLoaded) {
              final posts = state.posts;

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: MasonryGridView.builder(
                  gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // Number of columns
                  ),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final image = posts[index].images![0];
                    final post = posts[index];

                    if (image.contains('.mp4')) {
                      return VideoTileWidget(
                        videoUrl: image,
                        post: post,
                        user: UserEntity(),
                      );
                    }

                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => PostViewScreen(
                              post: post,
                              user: widget.user,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.all(5),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: image != null && image.isNotEmpty
                              ? Image.network(image)
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
            return SizedBox();
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
          print("Video loading error: $error");
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
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) =>
                PostViewScreen(post: widget.post, user: widget.user)));
      },
      child: Container(
        margin: EdgeInsets.all(5),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: _isInitialized
              ? Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                    Positioned.fill(
                      child: Center(
                        child: Icon(
                          Icons.play_arrow,
                          color: AppColor.whiteColor,
                          size: 40,
                        ),
                      ),
                    ),
                    Positioned.fill(
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
