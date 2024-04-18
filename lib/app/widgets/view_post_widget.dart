import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialseed/app/screens/post/view_post_screen.dart';
import 'package:socialseed/app/widgets/image_tile_widget.dart';
import 'package:socialseed/app/widgets/more_menu_items.dart';
import 'package:socialseed/app/widgets/post_widget.dart';
import 'package:socialseed/app/widgets/view_post_card.dart';
import 'package:socialseed/domain/entities/post_entity.dart';
import 'package:socialseed/domain/entities/user_entity.dart';
import 'package:socialseed/utils/constants/page_const.dart';

import '../../utils/constants/asset_const.dart';
import '../../utils/constants/color_const.dart';
import '../../utils/constants/text_const.dart';
import '../cubits/post/post_cubit.dart';

Widget postCardWidget(BuildContext context, List<PostEntity> posts,
    UserEntity currentUser, bool isSinglePost) {
  return ListView.builder(
    itemCount: posts.length,
    itemBuilder: (ctx, idx) {
      PostEntity post = posts[idx];

      double size = 380;

      String caption = posts[idx].content.toString();

      int totalLines = (caption.length / 25).ceil();
      size = size + totalLines * 25;

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
                                Text(
                                  post.username.toString(),
                                  style:
                                      TextConst.MediumStyle(14, Colors.black),
                                ),
                                sizeHor(5),
                                Image.asset(
                                  'assets/3963-verified-developer-badge-red 1.png',
                                  height: 18,
                                  width: 18,
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
                            sizeVar(5),
                            Container(
                              height: 20,
                              width: 60,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 144, 205, 255),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Text(
                                  'Home',
                                  style: TextConst.headingStyle(
                                      12, AppColor.whiteColor),
                                ),
                              ),
                            ),
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
                          PostViewScreen(post: post, user: currentUser))),
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
              if (post.images!.length == 1)
                Container(
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
              if (post.images!.length == 2)
                Row(
                  children: [
                    Expanded(
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
                    Expanded(
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
                  ],
                ),
              if (post.images!.length == 3)
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: imageTile(imageId: post.images![0])),
                        Expanded(child: imageTile(imageId: post.images![1])),
                      ],
                    ),
                    imageTile(imageId: post.images![2]),
                  ],
                ),
              if (post.images!.length >= 4)
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: imageTile(imageId: post.images![0])),
                        Expanded(child: imageTile(imageId: post.images![1])),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: imageTile(imageId: post.images![2])),
                        Expanded(
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
                        !post.likes!.contains(currentUser.uid)
                            ? IconConst.likeIcon
                            : IconConst.likePressedIcon,
                        post.totalLikes),
                  ),
                  sizeHor(10),
                  postItem(IconConst.commentIcon, post.totalComments),
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
