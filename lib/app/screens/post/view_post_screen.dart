import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialseed/app/cubits/comment/cubit/comment_cubit.dart';
import 'package:socialseed/app/cubits/post/post_cubit.dart';
import 'package:socialseed/app/screens/post/edit_post_screen.dart';
import 'package:socialseed/app/widgets/comment_card_widget.dart';
import 'package:socialseed/app/widgets/more_menu_items.dart';
import 'package:socialseed/app/widgets/view_post_card.dart';
import 'package:socialseed/app/widgets/view_post_widget.dart';
import 'package:socialseed/domain/entities/comment_entity.dart';
import 'package:socialseed/domain/entities/post_entity.dart';
import 'package:socialseed/domain/entities/user_entity.dart';
import 'package:socialseed/utils/constants/asset_const.dart';
import 'package:socialseed/utils/constants/color_const.dart';
import 'package:socialseed/utils/constants/page_const.dart';
import 'package:socialseed/utils/constants/text_const.dart';
import 'package:uuid/uuid.dart';

class PostViewScreen extends StatefulWidget {
  final PostEntity post;
  final UserEntity user;

  const PostViewScreen({
    super.key,
    required this.post,
    required this.user,
  });

  @override
  State<PostViewScreen> createState() => _PostViewScreenState();
}

class _PostViewScreenState extends State<PostViewScreen> {
  bool isLiked = false;
  num? totalLikes = 0;

  double size = 380;

  String caption = '';
  int totalLines = 0;
  bool isPressed = false;

  final _commentController = TextEditingController();

  @override
  void initState() {
    caption = widget.post.content.toString();

    totalLines = (caption.length / 25).ceil();
    size = size + totalLines * 25;

    isLiked = widget.post.likes?.contains(widget.user.uid) ?? false;
    totalLikes = widget.post.totalLikes ?? 0;
    super.initState();

    BlocProvider.of<CommentCubit>(context)
      ..getComments(postId: widget.post.postid.toString());
  }

  List<PopupMenuEntry<MenuOptions>> getPopupMenuItems() {
    return [
      PopupMenuItem<MenuOptions>(
        value: MenuOptions.Edit,
        child: GestureDetector(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (ctx) =>
                  EditPostScreen(currentUser: widget.user, post: widget.post))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Icon(Icons.edit),
              sizeHor(10),
              const Text('Edit'),
            ],
          ),
        ),
      ),
      PopupMenuItem<MenuOptions>(
        value: MenuOptions.Delete,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Icon(Icons.delete),
            sizeHor(10),
            const Text('Delete'),
          ],
        ),
      ),
      PopupMenuItem<MenuOptions>(
        value: MenuOptions.Copy,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Icon(Icons.copy_rounded),
            sizeHor(10),
            const Text('Copy Link'),
          ],
        ),
      ),
      PopupMenuItem<MenuOptions>(
        value: MenuOptions.Report,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Icon(Icons.report),
            sizeHor(10),
            const Text('Report'),
          ],
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: AppColor.whiteColor,
        backgroundColor: AppColor.whiteColor,
        title: const Text('View Post'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
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
                              backgroundImage: NetworkImage(
                                  widget.post.profileId.toString()),
                              radius: 20.0,
                            ),
                            const SizedBox(width: 10.0),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      widget.post.username.toString(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                    sizeHor(5),
                                    Image.asset(
                                      'assets/3963-verified-developer-badge-red 1.png',
                                      height: 18,
                                      width: 18,
                                    ),
                                    sizeHor(5),
                                    const CircleAvatar(
                                      radius: 3,
                                      backgroundColor: AppColor.textGreyColor,
                                    ),
                                    sizeHor(5),
                                    Text(
                                      getTime(widget.post.creationDate),
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
                                    color: const Color.fromARGB(
                                        255, 144, 205, 255),
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
                    child: Container(
                      padding: const EdgeInsets.only(
                        left: 12,
                        top: 5,
                      ),
                      width: double.infinity,
                      child: Text(
                        widget.post.content.toString(),
                        maxLines: null,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 250,
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CachedNetworkImage(
                        imageUrl: widget.post.images!.first,
                        placeholder: (ctx, url) => Container(
                          color: Colors.grey,
                        ),
                        errorWidget: (ctx, url, err) => const Icon(Icons.error),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      sizeHor(10),
                      GestureDetector(
                        onTap: () {
                          BlocProvider.of<PostCubit>(context)
                              .likePost(post: widget.post);
                          setState(() {
                            isLiked = !isLiked;
                            if (isLiked) {
                              totalLikes = (totalLikes ?? 0) + 1;
                            } else {
                              totalLikes = (totalLikes ?? 0) - 1;
                            }
                          });
                        },
                        child: postItem(
                            !isLiked
                                ? IconConst.likeIcon
                                : IconConst.likePressedIcon,
                            totalLikes),
                      ),
                      sizeHor(10),
                      postItem(
                          IconConst.commentIcon, widget.post.totalComments),
                      sizeHor(10),
                      postItem(IconConst.shareIcon, widget.post.shares),
                    ],
                  )
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "View All",
                  style: TextConst.headingStyle(
                    16,
                    AppColor.redColor,
                  ),
                ),
              ),
            ),
            Container(
              height: 400,
              child: BlocBuilder<CommentCubit, CommentState>(
                builder: (context, state) {
                  if (state is CommentLoading) {
                    return const CircularProgressIndicator();
                  }

                  if (state is CommentLoaded) {
                    final comments = state.comments;

                    return ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: (comments.length <= 3) ? comments.length : 3,
                        itemBuilder: (ctx, idx) {
                          final comment = comments[idx];

                          return commentCard(comment);
                        });
                  }

                  if (state is CommentFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error has occurred')));
                  }

                  return SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (isPressed)
            Expanded(
              child: Container(
                  margin: const EdgeInsets.all(14),
                  width: 200,
                  decoration: BoxDecoration(
                    color: AppColor.whiteColor,
                    border: Border.all(
                      color: AppColor.redColor,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.shade300,
                        blurRadius: 2,
                        spreadRadius: 1,
                      )
                    ],
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(13.0),
                    child: TextField(
                      maxLines: null,
                      controller: _commentController,
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration(
                        hintText: 'Comment',
                        border: InputBorder.none,
                      ),
                    ),
                  )),
            ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColor.redColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: IconButton(
                onPressed: () {
                  if (isPressed == false) {
                    setState(() {
                      isPressed = true;
                    });
                  } else if (_commentController.text.isNotEmpty) {
                    BlocProvider.of<CommentCubit>(context)
                        .createComment(
                            comment: CommentEntity(
                      commentId: const Uuid().v4(),
                      postId: widget.post.postid,
                      creatorUid: widget.user.uid,
                      content: _commentController.text,
                      username: widget.post.username,
                      profileUrl: widget.user.imageUrl,
                      createAt: Timestamp.now(),
                      likes: [],
                    ))
                        .then((value) {
                      setState(() {
                        _commentController.clear();
                        isPressed = false;
                      });
                    });
                  } else {
                    debugPrint("NO ARGUMENT");
                    setState(() {
                      isPressed = false;
                    });
                  }
                },
                icon: Image.asset(
                  IconConst.commentIcon,
                  height: 35,
                  width: 35,
                ),
              ),
            ),
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}