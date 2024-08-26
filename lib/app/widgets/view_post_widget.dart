import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:socialseed/app/screens/home_screen.dart';
import 'package:socialseed/app/screens/post/view_post_screen.dart';
import 'package:socialseed/app/screens/user/single_profile_screen.dart';
import 'package:socialseed/app/widgets/image_tile_widget.dart';
import 'package:socialseed/app/widgets/more_menu_items.dart';
import 'package:socialseed/app/widgets/post_widget.dart';
import 'package:socialseed/app/widgets/view_post_card.dart';
import 'package:socialseed/domain/entities/post_entity.dart';
import 'package:socialseed/domain/entities/user_entity.dart';
import 'package:socialseed/utils/constants/page_const.dart';

import '../../utils/constants/asset_const.dart';
import '../../utils/constants/color_const.dart';
import '../../utils/constants/tags_const.dart';
import '../../utils/constants/text_const.dart';
import '../cubits/post/post_cubit.dart';
import '../screens/post/edit_post_screen.dart';
import 'package:socialseed/dependency_injection.dart' as di;

Widget postCardWidget(
    BuildContext context, List<PostEntity> posts, UserEntity user, String uid) {
  return ListView.builder(
    physics: const ScrollPhysics(),
    shrinkWrap: true,
    itemCount: posts.length,
    itemBuilder: (ctx, idx) {
      PostEntity post = posts[idx];

      double size = (post.images!.isEmpty) ? 150 : 380;

      String caption = posts[idx].content.toString();

      int totalLines = (caption.length / 25).ceil();
      size = size + totalLines * 25;

      List<PopupMenuEntry<MenuOptions>> getPopupMenuItems() {
        return [
          PopupMenuItem<MenuOptions>(
            value: MenuOptions.Edit,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(Icons.edit),
                sizeHor(10),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (ctx) =>
                          EditPostScreen(currentUser: user, post: post))),
                  child: const Text('Edit'),
                ),
              ],
            ),
          ),
          PopupMenuItem<MenuOptions>(
            value: MenuOptions.Delete,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(Icons.delete),
                sizeHor(10),
                GestureDetector(
                  onTap: () => di.sl<PostCubit>().deletePost(post: post).then(
                      // ignore: use_build_context_synchronously
                      (value) => Navigator.of(context).push(MaterialPageRoute(
                          builder: (ctx) =>
                              HomeScreen(uid: user.uid.toString())))),
                  child: const Text('Delete'),
                ),
              ],
            ),
          ),
        ];
      }

      return Container(
          height: size,
          width: double.infinity,
          margin: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            border: Border.all(color: AppColor.greyShadowColor),
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
                                    style:
                                        TextConst.MediumStyle(14, Colors.black),
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
                                  ),
                                ),
                              ],
                            ),
                            if (user.uid != post.uid)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (post.work!.toLowerCase() != "none" &&
                                      user.work!.toLowerCase() ==
                                          post.work!.toLowerCase())
                                    mutualTag("work"),
                                  if (post.school!.toLowerCase() != "none" &&
                                      user.school!.toLowerCase() ==
                                          post.school!.toLowerCase())
                                    mutualTag("school"),
                                  if (post.college!.toLowerCase() != "none" &&
                                      user.college!.toLowerCase() ==
                                          post.college!.toLowerCase())
                                    mutualTag("college"),
                                  if (post.location!.toLowerCase() != "none" &&
                                      user.location!.toLowerCase() ==
                                          post.location!.toLowerCase())
                                    mutualTag("home"),
                                ],
                              ),
                            if (user.uid == post.uid)
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
                    PopupMenuButton(
                      itemBuilder: (ctx) => getPopupMenuItems(),
                      surfaceTintColor: Colors.white,
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
                          PostViewScreen(post: post, user: user))),
                  child: Container(
                    padding: const EdgeInsets.only(
                      left: 12,
                      top: 5,
                    ),
                    width: double.infinity,
                    child: Text(
                      posts[idx].content.toString(),
                      maxLines: null,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.1,
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
                                post.images![idx],
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
                  child: Container(
                    height: 250,
                    width: double.infinity,
                    padding: const EdgeInsets.all(12.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CachedNetworkImage(
                        imageUrl: post.images![0],
                        placeholder: (ctx, url) => Container(
                          color: Colors.grey,
                        ),
                        errorWidget: (ctx, url, err) => const Icon(Icons.error),
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
                                      post.images![idx],
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
                        child: Container(
                          height: 250,
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
                                      post.images![idx],
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
                        child: Container(
                          height: 250,
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
                                              post.images![idx],
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
                                              post.images![idx],
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
                                      post.images![idx],
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
                                              post.images![idx],
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
                                              post.images![idx],
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
                                              post.images![idx],
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
                                        borderRadius: BorderRadius.circular(16),
                                        child: Image.network(
                                          post.images![idx],
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
                  GestureDetector(
                    onTap: () {
                      BlocProvider.of<PostCubit>(context).likePost(post: post);
                    },
                    child: postItem(
                        !post.likes!.contains(user.uid)
                            ? IconConst.likeIcon
                            : IconConst.likePressedIcon,
                        post.totalLikes),
                  ),
                  sizeHor(10),
                  GestureDetector(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (ctx) =>
                              PostViewScreen(post: post, user: user))),
                      child:
                          postItem(IconConst.commentIcon, post.totalComments)),
                  sizeHor(10),
                  postItem(IconConst.shareIcon, post.shares),
                ],
              )
            ],
          ));
    },
  );
}

String getTime(Timestamp? time) {
  int totalTime = (Timestamp.now().seconds - time!.seconds).toInt();

  if (totalTime < 60) {
    return '${totalTime}s ago';
  } else if (totalTime > 60 && totalTime <= 3600) {
    return '${totalTime ~/ 60}m ago';
  } else if (totalTime > 3600 && totalTime <= 86400) {
    return '${totalTime ~/ 3600}hr ago';
  } else {
    return '${totalTime ~/ 86400}d ago';
  }
}
