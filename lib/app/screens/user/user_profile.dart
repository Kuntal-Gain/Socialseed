import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialseed/app/cubits/auth/auth_cubit.dart';
import 'package:socialseed/app/cubits/post/post_cubit.dart';
import 'package:socialseed/app/cubits/users/user_cubit.dart';
import 'package:socialseed/app/screens/user/edit_profile_screen.dart';
import 'package:socialseed/domain/entities/post_entity.dart';

import 'package:socialseed/domain/entities/user_entity.dart';
import 'package:socialseed/domain/usecases/user/get_current_uid_usecase.dart';
import 'package:socialseed/utils/constants/color_const.dart';
import 'package:socialseed/utils/constants/page_const.dart';
import 'package:socialseed/utils/constants/text_const.dart';

import '../../cubits/get_single_other_user/get_single_other_user_cubit.dart';
import '../../widgets/profile_widget.dart';
import 'package:socialseed/dependency_injection.dart' as di;

import '../../widgets/view_post_widget.dart';

class UserProfile extends StatefulWidget {
  final String otherUid;
  const UserProfile({super.key, required this.otherUid});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile>
    with SingleTickerProviderStateMixin {
  late TabController _controller;

  int currentIdx = 0;
  List<String> images = [];
  String currentUid = "";

  Future<void> fetchPosts(String uid) async {
    // Step 1: Fetch the user's document from Firestore
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (userDoc.exists) {
      // Step 2: Get the list of post IDs from the user's document
      List<dynamic> postIds = userDoc.data()!['posts'];

      // Step 3: Fetch the post images for each post ID
      for (String postId in postIds) {
        final postDoc = await FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .get();

        if (postDoc.exists) {
          List<dynamic> postImages = postDoc.data()!['images'];
          setState(() {
            images.addAll(postImages.cast<String>());
          });
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 3, vsync: this);
    BlocProvider.of<GetSingleOtherUserCubit>(context)
        .getSingleOtherUser(otherUid: widget.otherUid);
    BlocProvider.of<PostCubit>(context).getPosts(post: const PostEntity());

    di.sl<GetCurrentUidUsecase>().call().then((value) {
      setState(() {
        currentUid = value;
      });
    });

    fetchPosts(widget.otherUid);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetSingleOtherUserCubit, GetSingleOtherUserState>(
      builder: (ctx, state) {
        if (state is GetSingleOtherUserLoaded) {
          final user = state.otherUser;

          return Scaffold(
            appBar: AppBar(
              surfaceTintColor: AppColor.whiteColor,
              elevation: 0,
              backgroundColor: AppColor.whiteColor,
              title: Text('${user.fullname.toString()} • Profile'),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Scrollbar(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          SizedBox(
                            height: 325,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // cover image
                                Container(
                                  height: 140,
                                  width: double.infinity,
                                  margin: const EdgeInsets.all(12),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.asset(
                                      'assets/post-2.jpg',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                // profile data
                                Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          user.fullname ??
                                              '', // Use empty string as default if fullname is null
                                          style: TextConst.headingStyle(
                                            18,
                                            AppColor.blackColor,
                                          ),
                                        ),
                                        sizeHor(10),
                                        if (user.isVerified!)
                                          Image.asset(
                                              'assets/3963-verified-developer-badge-red 1.png')
                                      ],
                                    ),
                                    sizeVar(10),
                                    Container(
                                      height: 30,
                                      width: 100,
                                      decoration: BoxDecoration(
                                        color: (user.activeStatus ?? false)
                                            ? AppColor.redColor
                                            : AppColor.greyShadowColor,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Center(
                                        child: Text(
                                          (user.activeStatus ?? false)
                                              ? 'Online Now'
                                              : 'Offline',
                                          style: TextConst.headingStyle(
                                              14, AppColor.whiteColor),
                                        ),
                                      ),
                                    ),
                                    sizeVar(10),
                                    Text(
                                      user.bio.toString(),
                                      style: TextConst.RegularStyle(
                                          15, AppColor.blackColor),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 90,
                            left: 135,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: (user.activeStatus ?? false)
                                      ? AppColor.redColor
                                      : AppColor.greyShadowColor,
                                  width: 5,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 55,
                                backgroundImage:
                                    NetworkImage(user.imageUrl.toString()),
                              ),
                            ),
                          ),
                        ],
                      ),

                      if (currentUid != user.uid)
                        Container(
                          height: 100,
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 15),
                          child: Row(
                            children: [
                              if (!user.friends!.contains(currentUid))
                                Expanded(
                                  flex: 3,
                                  child: GestureDetector(
                                    onTap: () {
                                      BlocProvider.of<UserCubit>(context)
                                          .sendRequestUsecase(user);
                                    },
                                    child: Container(
                                      height: 60,
                                      margin: const EdgeInsets.all(3),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColor.redColor,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          (!user.requests!.contains(currentUid))
                                              ? Image.asset(
                                                  'assets/icons/add-user.png',
                                                  height: 20,
                                                  width: 20,
                                                  color: AppColor.whiteColor,
                                                )
                                              : const Icon(
                                                  Icons.cancel,
                                                  color: Colors.white,
                                                ),
                                          Text(
                                            (!user.requests!
                                                    .contains(currentUid))
                                                ? 'Send Request'
                                                : 'Cancel Request',
                                            style: TextConst.headingStyle(
                                                12, AppColor.whiteColor),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              if (user.friends!.contains(currentUid))
                                Expanded(
                                  flex: 3,
                                  child: GestureDetector(
                                    onTap: () {
                                      // toggle to remove friend
                                    },
                                    child: Container(
                                      height: 60,
                                      margin: const EdgeInsets.all(3),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColor.redColor,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            'assets/icons/check-mark.png',
                                            height: 20,
                                            width: 20,
                                            color: AppColor.whiteColor,
                                          ),
                                          sizeHor(10),
                                          Text(
                                            'Friend',
                                            style: TextConst.headingStyle(
                                                12, AppColor.whiteColor),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              Expanded(
                                flex: 2,
                                child: GestureDetector(
                                  onTap: () {
                                    if (user.followers!.contains(currentUid)) {
                                      BlocProvider.of<UserCubit>(context)
                                          .unFollowUser(user: user);
                                    } else {
                                      BlocProvider.of<UserCubit>(context)
                                          .followUser(user: user);
                                    }
                                  },
                                  child: Container(
                                    height: 60,
                                    padding: const EdgeInsets.all(12),
                                    margin: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: AppColor.whiteColor,
                                      border:
                                          Border.all(color: AppColor.redColor),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Image.asset(
                                          'assets/icons/followers.png',
                                          height: 20,
                                          width: 20,
                                          color: AppColor.redColor,
                                        ),
                                        Text(
                                          (user.followers!.contains(currentUid))
                                              ? 'UnFollow'
                                              : 'Follow',
                                          style: TextConst.headingStyle(
                                              12, AppColor.redColor),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: AspectRatio(
                                  aspectRatio: 1 / 1,
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    margin: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border:
                                          Border.all(color: AppColor.redColor),
                                    ),
                                    child: Image.asset(
                                      'assets/icons/messenger.png',
                                      height: 35,
                                      width: 35,
                                      color: AppColor.redColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      Container(
                        margin: const EdgeInsets.all(16),
                        height: 100,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: AppColor.greyShadowColor),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Center(
                              child: Text(
                                '${user.friends!.length}\nFriends',
                                textAlign: TextAlign.center,
                                style: TextConst.MediumStyle(
                                    16, AppColor.blackColor),
                              ),
                            ),
                            Center(
                              child: Text(
                                '${user.followerCount!}\nFollowers',
                                textAlign: TextAlign.center,
                                style: TextConst.MediumStyle(
                                    16, AppColor.blackColor),
                              ),
                            ),
                            Center(
                              child: Text(
                                '${user.posts!.length}\nPosts',
                                textAlign: TextAlign.center,
                                style: TextConst.MediumStyle(
                                    16, AppColor.blackColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TabBar(
                        onTap: (val) {
                          setState(() {
                            currentIdx = val;
                          });
                        },
                        controller: _controller,
                        dividerHeight: 0,
                        indicatorColor: AppColor.redColor,
                        tabs: const [
                          Text('Post'),
                          Text('Media'),
                          Text('About'),
                        ],
                      ),
                      sizeVar(20),
                      // posts

                      BlocBuilder<PostCubit, PostState>(
                        builder: (context, state) {
                          if (state is PostLoading) {
                            // ignore: avoid_print
                            print("POST LOADING....");
                            return const Center(
                              child: CircularProgressIndicator(
                                color: AppColor.redColor,
                              ),
                            );
                          }

                          if (state is PostLoaded) {
                            // ignore: avoid_print
                            print("POST LOADED IS TRIGGERED");
                            final posts = state.posts
                                .where((post) => post.uid == user.uid)
                                .toList();

                            if (currentIdx == 0) {
                              return SizedBox(
                                height: 450,
                                child: Scrollbar(
                                    child: postCardWidget(context, posts, user,
                                        user.uid.toString())),
                              );
                            } else if (currentIdx == 1) {
                              return SizedBox(
                                height: 450,
                                child: GridView.builder(
                                  itemCount: images.length,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    mainAxisSpacing: 0,
                                    crossAxisSpacing: 0,
                                    childAspectRatio: 1,
                                  ),
                                  itemBuilder: (ctx, idx) {
                                    return GestureDetector(
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
                                                    images[idx],
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
                                      child: Container(
                                        margin: const EdgeInsets.all(10),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          child: Image.network(
                                            images[idx],
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            } else {
                              return getInformtion(user, context, currentUid);
                            }
                          }

                          if (state is PostFailure) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Something went wrong')));
                          }

                          return const SizedBox();
                        },
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        } else if (state is GetSingleOtherUserLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return const SizedBox();
      },
    );
  }
}

Widget getInformtion(UserEntity user, BuildContext ctx, String currentUid) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(
      children: [
        infoCard(Icons.work, "Work at ", user.work.toString()),
        infoCard(Icons.school, "Studied at ", user.college.toString()),
        infoCard(Icons.school, "Went to ", user.school.toString()),
        infoCard(Icons.home, "Live at ", user.location.toString()),
        if (user.uid.toString() == currentUid)
          getButton(
            "Edit Profile",
            () => Navigator.of(ctx).push(MaterialPageRoute(
                builder: (ctx) => EditProfileScreen(
                      user: user,
                    ))),
            true,
          ),
        if (user.uid.toString() == currentUid)
          getButton(
            "Logout",
            () {
              BlocProvider.of<AuthCubit>(ctx).logout();
            },
            false,
          ),
      ],
    ),
  );
}
