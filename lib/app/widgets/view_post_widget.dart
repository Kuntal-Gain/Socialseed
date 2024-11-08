import 'package:animated_menu/animated_menu.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialseed/app/cubits/archivepost/archivepost_cubit.dart';
import 'package:socialseed/app/cubits/savedcontent/savedcontent_cubit.dart';

import 'package:socialseed/app/screens/post/view_post_screen.dart';
import 'package:socialseed/app/screens/user/single_profile_screen.dart';
import 'package:socialseed/app/widgets/image_tile_widget.dart';
import 'package:socialseed/app/widgets/post_widget.dart';
import 'package:socialseed/app/widgets/view_post_card.dart';
import 'package:socialseed/domain/entities/post_entity.dart';
import 'package:socialseed/domain/entities/user_entity.dart';
import 'package:socialseed/utils/constants/page_const.dart';
import 'package:socialseed/utils/custom/custom_snackbar.dart';

import '../../utils/constants/asset_const.dart';
import '../../utils/constants/color_const.dart';
import '../../utils/constants/tags_const.dart';
import '../../utils/constants/text_const.dart';
import '../cubits/post/post_cubit.dart';
import '../screens/post/edit_post_screen.dart';

class PostCardWidget extends StatefulWidget {
  final List<PostEntity> posts;
  final UserEntity user;
  final String uid;
  const PostCardWidget(
      {super.key, required this.posts, required this.user, required this.uid});

  @override
  State<PostCardWidget> createState() => _PostCardWidgetState();
}

class _PostCardWidgetState extends State<PostCardWidget> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    var mq = MediaQuery.of(context).size;

    return ListView.builder(
      physics: const ScrollPhysics(),
      shrinkWrap: true,
      itemCount: widget.posts.length,
      itemBuilder: (ctx, idx) {
        PostEntity post = widget.posts[idx];

        double size =
            (post.images!.isEmpty) ? mq.height * 0.1 : mq.height * 0.35;

        String caption = widget.posts[idx].content.toString();

        double lineHeight = mq.height * 0.015;
        int totalLines = (caption.length / 40).ceil();
        size = size + (totalLines * lineHeight);

        num totalLikes = post.totalLikes ?? 0; // Local variable

        return SingleChildScrollView(
          child: Container(
            height: size + mq.height * 0.05,
            width: double.infinity,
            margin: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              boxShadow: const [
                BoxShadow(
                  color: AppColor.greyShadowColor,
                  spreadRadius: 1,
                  blurRadius: 1,
                ),
              ],
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage:
                                NetworkImage(post.profileId.toString()),
                            radius: 20.0,
                          ),
                          const SizedBox(width: 10.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (ctx) => SingleUserProfilePage(
                                            otherUserId: post.uid.toString()),
                                      ),
                                    ),
                                    child: Text(
                                      post.username.toString(),
                                      style: TextConst.headingStyle(
                                          14, AppColor.redColor),
                                    ),
                                  ),
                                  if (post.isVerified!)
                                    Row(
                                      children: [
                                        sizeHor(5),
                                        Image.asset(
                                          'assets/3963-verified-developer-badge-red 1.png',
                                          height: 18,
                                          width: 18,
                                        ),
                                      ],
                                    ),
                                  sizeHor(5),
                                  if (post.location!.isNotEmpty)
                                    getLocation(post.location!),
                                  sizeHor(5),
                                  const CircleAvatar(
                                    radius: 3,
                                    backgroundColor: AppColor.textGreyColor,
                                  ),
                                  sizeHor(5),
                                  Text(
                                    getTime(post.creationDate),
                                    style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14.0,
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                ],
                              ),
                              if (widget.user.uid != post.uid)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (post.work!.toLowerCase() != "none" &&
                                        widget.user.work!.toLowerCase() ==
                                            post.work!.toLowerCase())
                                      mutualTag("work"),
                                    if (post.school!.toLowerCase() != "none" &&
                                        widget.user.school!.toLowerCase() ==
                                            post.school!.toLowerCase())
                                      mutualTag("school"),
                                    if (post.college!.toLowerCase() != "none" &&
                                        widget.user.college!.toLowerCase() ==
                                            post.college!.toLowerCase())
                                      mutualTag("college"),
                                    if (post.location!.toLowerCase() !=
                                            "none" &&
                                        widget.user.location!.toLowerCase() ==
                                            post.location!.toLowerCase())
                                      mutualTag("home"),
                                  ],
                                ),
                              if (widget.user.uid == post.uid)
                                Container(
                                  width: 55,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: AppColor.redColor,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  margin: const EdgeInsets.all(5),
                                  child: Center(
                                    child: Text(
                                      "You",
                                      style: TextConst.headingStyle(
                                        14,
                                        AppColor.whiteColor,
                                      ),
                                    ),
                                  ),
                                )
                            ],
                          ),
                        ],
                      ),
                      if (FirebaseAuth.instance.currentUser!.uid == post.uid)
                        GestureDetector(
                          onTapDown: (details) {
                            showAnimatedMenu(
                              context: context,
                              preferredAnchorPoint: Offset(
                                details.globalPosition.dx,
                                details.globalPosition.dy,
                              ),
                              isDismissable: true,
                              useRootNavigator: true,
                              menu: AnimatedMenu(
                                items: [
                                  FadeIn(
                                    child: Material(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        height: mq.height * 0.20,
                                        width: mq.width * 0.3,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                BlocProvider.of<PostCubit>(
                                                        context)
                                                    .deletePost(post: post);
                                                Navigator.pop(context);
                                              },
                                              child: getMenuItem(
                                                  Icons.delete_forever,
                                                  "Delete"),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        EditPostScreen(
                                                      currentUser: widget.user,
                                                      post: post,
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: getMenuItem(
                                                  Icons.edit, "Edit"),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                BlocProvider.of<
                                                            ArchivepostCubit>(
                                                        context)
                                                    .archivePost(post);

                                                Navigator.pop(context);
                                              },
                                              child: getMenuItem(
                                                  Icons.archive_rounded,
                                                  "Archive"),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Image.asset(
                            IconConst.moreIcon,
                            height: 25,
                            width: 25,
                          ),
                        )
                    ],
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (ctx) =>
                            PostViewScreen(post: post, user: widget.user))),
                    child: Container(
                      padding: const EdgeInsets.only(
                        left: 12,
                        top: 2,
                        right: 12,
                        bottom: 2,
                      ),
                      width: double.infinity,
                      child: Text(
                        widget.posts[idx].content.toString(),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
                if (post.images!.isEmpty) const SizedBox(),
                if (post.images!.length == 1)
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: ctx,
                        builder: (_) => Dialog(
                          backgroundColor: Colors.transparent,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  post.images![0],
                                  width: mq.width * 0.8,
                                  height: mq.height * 0.6,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                },
                                child: const Text(
                                  "Close",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      height: mq.height * 0.25,
                      width: mq.width * 1,
                      padding: const EdgeInsets.all(12.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CachedNetworkImage(
                          imageUrl: post.images![0],
                          placeholder: (ctx, url) => Container(
                            color: Colors.grey,
                          ),
                          errorWidget: (ctx, url, err) =>
                              const Icon(Icons.error),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                if (post.images!.length == 2)
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: ctx,
                              builder: (_) => Dialog(
                                backgroundColor: Colors.transparent,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.network(
                                        post.images![0],
                                        width: mq.width * 0.8,
                                        height: mq.height * 0.6,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(ctx).pop();
                                      },
                                      child: const Text(
                                        "Close",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          child: Container(
                            height: mq.height * 0.3,
                            width: double.infinity,
                            padding: const EdgeInsets.all(12.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: CachedNetworkImage(
                                imageUrl: post.images![0],
                                placeholder: (ctx, url) => Container(
                                  color: Colors.grey,
                                ),
                                errorWidget: (ctx, url, err) =>
                                    const Icon(Icons.error),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: ctx,
                              builder: (_) => Dialog(
                                backgroundColor: Colors.transparent,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.network(
                                        post.images![1],
                                        width: mq.width * 0.8,
                                        height: mq.height * 0.6,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(ctx).pop();
                                      },
                                      child: const Text(
                                        "Close",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          child: Container(
                            height: mq.height * 0.3,
                            width: double.infinity,
                            padding: const EdgeInsets.all(12.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: CachedNetworkImage(
                                imageUrl: post.images![1],
                                placeholder: (ctx, url) => Container(
                                  color: Colors.grey,
                                ),
                                errorWidget: (ctx, url, err) =>
                                    const Icon(Icons.error),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                if (post.images!.length == 3)
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: ctx,
                                      builder: (_) => Dialog(
                                        backgroundColor: Colors.transparent,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              child: Image.network(
                                                post.images![0],
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(ctx).pop();
                                              },
                                              child: const Text(
                                                "Close",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  child: imageTile(imageId: post.images![0]))),
                          Expanded(
                              child: GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: ctx,
                                      builder: (_) => Dialog(
                                        backgroundColor: Colors.transparent,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              child: Image.network(
                                                post.images![1],
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(ctx).pop();
                                              },
                                              child: const Text(
                                                "Close",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  child: imageTile(imageId: post.images![1]))),
                        ],
                      ),
                      GestureDetector(
                          onTap: () {
                            showDialog(
                              context: ctx,
                              builder: (_) => Dialog(
                                backgroundColor: Colors.transparent,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.network(
                                        post.images![2],
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(ctx).pop();
                                      },
                                      child: const Text(
                                        "Close",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          child: imageTile(imageId: post.images![2])),
                    ],
                  ),
                if (post.images!.length >= 4)
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: ctx,
                                      builder: (_) => Dialog(
                                        backgroundColor: Colors.transparent,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              child: Image.network(
                                                post.images![0],
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(ctx).pop();
                                              },
                                              child: const Text(
                                                "Close",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  child: imageTile(imageId: post.images![0]))),
                          Expanded(
                              child: GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: ctx,
                                      builder: (_) => Dialog(
                                        backgroundColor: Colors.transparent,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              child: Image.network(
                                                post.images![1],
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(ctx).pop();
                                              },
                                              child: const Text(
                                                "Close",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  child: imageTile(imageId: post.images![1]))),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: ctx,
                                      builder: (_) => Dialog(
                                        backgroundColor: Colors.transparent,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              child: Image.network(
                                                post.images![2],
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(ctx).pop();
                                              },
                                              child: const Text(
                                                "Close",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  child: imageTile(imageId: post.images![2]))),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: ctx,
                                  builder: (_) => Dialog(
                                    backgroundColor: Colors.transparent,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          child: Image.network(
                                            post.images![3],
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(ctx).pop();
                                          },
                                          child: const Text(
                                            "Close",
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.all(12),
                                height: 125,
                                width: double.infinity,
                                decoration: const BoxDecoration(),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: CachedNetworkImage(
                                        imageUrl: post.images![3],
                                        placeholder: (ctx, url) => Container(
                                          color: Colors.grey,
                                        ),
                                        errorWidget: (ctx, url, err) =>
                                            const Icon(Icons.error),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Container(
                                      color: Colors.black.withOpacity(
                                          0.5), // Adjust opacity as needed
                                      child: Center(
                                        child: Text(
                                          "${post.images!.length - 3}+",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                Row(
                  children: [
                    sizeHor(10),

                    // like

                    // Like button with animation
                    GestureDetector(
                      onTap: () async {
                        bool wasLiked =
                            post.likes?.contains(widget.user.uid) ?? false;

                        // Optimistically update the UI
                        setState(() {
                          if (wasLiked) {
                            totalLikes--;
                            post.likes?.remove(widget.user.uid);
                          } else {
                            totalLikes++;
                            post.likes?.add(widget.user.uid);
                          }
                        });

                        // Perform the like operation asynchronously
                        try {
                          await BlocProvider.of<PostCubit>(context)
                              .likePost(post: post);
                        } catch (error) {
                          // Revert the UI state if the operation fails
                          setState(() {
                            if (wasLiked) {
                              post.likes?.add(widget.user.uid);
                              totalLikes;
                            } else {
                              post.likes?.remove(widget.user.uid);
                              totalLikes--;
                            }
                          });

                          // Optionally show an error message to the user
                          // ignore: use_build_context_synchronously
                          failureBar(context, "Failed to Like the Post");
                        }
                      },
                      child: postItem(
                          iconId: post.likes?.contains(widget.user.uid) ?? false
                              ? IconConst.likePressedIcon
                              : IconConst.likeIcon,
                          value: totalLikes),
                    ),

                    sizeHor(10),
                    GestureDetector(
                        onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (ctx) => PostViewScreen(
                                    post: post, user: widget.user))),
                        child: postItem(
                            iconId: IconConst.commentIcon,
                            value: post.totalComments)),
                    sizeHor(10),

                    if (post.images!.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          // Check if the post is already saved
                          final bool isAlreadySaved =
                              widget.user.savedContent?.contains(post.postid) ??
                                  false;

                          // Optimistically update the UI
                          setState(() {
                            // Toggle the saved state in the UI
                            if (isAlreadySaved) {
                              widget.user.savedContent
                                  ?.remove(post.postid); // Remove if it's saved
                            } else {
                              widget.user.savedContent
                                  ?.add(post.postid); // Add if it's not saved
                            }
                          });

                          // Save or unsave the post asynchronously
                          BlocProvider.of<SavedcontentCubit>(context)
                              .savePost(
                                  post) // Assumes this handles both save and unsave operations
                              .then((_) {
                            // ignore: use_build_context_synchronously
                            successBar(context,
                                isAlreadySaved ? "Post Unsaved" : "Post Saved");
                          }).catchError((error) {
                            // Revert the UI state if the operation fails
                            setState(() {
                              if (isAlreadySaved) {
                                widget.user.savedContent
                                    ?.add(post.postid); // Revert to saved
                              } else {
                                widget.user.savedContent
                                    ?.remove(post.postid); // Revert to unsaved
                              }
                            });
                            // ignore: use_build_context_synchronously
                            failureBar(context, "Something went wrong");
                          });
                        },
                        child: Container(
                          height: 25,
                          width: 25,
                          margin: const EdgeInsets.all(12),
                          child: Image.asset(
                            widget.user.savedContent?.contains(post.postid) ??
                                    false
                                ? IconConst
                                    .pressedSaveIcon // Show pressed icon if saved
                                : IconConst
                                    .saveIcon, // Show regular icon if not saved
                            color: widget.user.savedContent
                                        ?.contains(post.postid) ??
                                    false
                                ? AppColor.redColor
                                : AppColor.blackColor,
                          ),
                        ),
                      )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

String getTime(Timestamp? time) {
  int totalTime = (Timestamp.now().seconds - time!.seconds).toInt();

  if (totalTime < 60) {
    return 'Just Now';
  } else if (totalTime > 60 && totalTime <= 3600) {
    return '${totalTime ~/ 60}m ago';
  } else if (totalTime > 3600 && totalTime <= 86400) {
    return '${totalTime ~/ 3600}hr ago';
  } else {
    return '${totalTime ~/ 86400}d ago';
  }
}

Widget getMenuItem(IconData icon, String label) {
  return SizedBox(
    height: 50,
    child: Row(
      children: [
        sizeHor(10),
        Icon(
          icon,
          color: AppColor.redColor,
        ),
        sizeHor(10),
        Text(
          label,
          style: TextConst.headingStyle(16, AppColor.redColor),
        ),
      ],
    ),
  );
}
