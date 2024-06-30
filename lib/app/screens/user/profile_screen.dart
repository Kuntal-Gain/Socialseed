import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialseed/app/cubits/auth/auth_cubit.dart';
import 'package:socialseed/app/cubits/post/post_cubit.dart';
import 'package:socialseed/app/screens/user/edit_profile_screen.dart';
import 'package:socialseed/app/widgets/view_post_widget.dart';
import 'package:socialseed/domain/entities/post_entity.dart';

import 'package:socialseed/domain/entities/user_entity.dart';
import 'package:socialseed/utils/constants/color_const.dart';
import 'package:socialseed/utils/constants/page_const.dart';
import 'package:socialseed/utils/constants/text_const.dart';

import '../../widgets/profile_widget.dart';
import 'package:socialseed/dependency_injection.dart' as di;

class ProfileScreen extends StatefulWidget {
  final UserEntity user;
  final String currentUid;
  const ProfileScreen(
      {super.key, required this.user, required this.currentUid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _controller;

  int currentIdx = 0;
  List<String> images = [];

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 3, vsync: this);

    // Populate images list here
    BlocProvider.of<PostCubit>(context).stream.listen((state) {
      if (state is PostLoaded) {
        final posts = state.posts;
        for (var post in posts) {
          if (post.images!.length > 1) {
            images.addAll(post.images!.cast<String>());
          } else {
            images.add(post.images!.first.toString());
          }
        }
        setState(() {}); // Trigger a rebuild after populating images list
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) =>
            di.sl<PostCubit>()..getPosts(post: const PostEntity()),
        child: SafeArea(
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      widget.user.fullname.toString(),
                                      style: TextConst.headingStyle(
                                        18,
                                        AppColor.blackColor,
                                      ),
                                    ),
                                    sizeHor(10),
                                    Image.asset(
                                        'assets/3963-verified-developer-badge-red 1.png')
                                  ],
                                ),
                                sizeVar(10),
                                Container(
                                  height: 30,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    color: AppColor.redColor,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Online Now',
                                      style: TextConst.headingStyle(
                                          14, AppColor.whiteColor),
                                    ),
                                  ),
                                ),
                                sizeVar(10),
                                Text(
                                  widget.user.bio.toString(),
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
                              color: AppColor.redColor,
                              width: 5,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 55,
                            backgroundImage:
                                NetworkImage(widget.user.imageUrl.toString()),
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (widget.currentUid != widget.user.uid)
                    Container(
                      height: 100,
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 15),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
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
                                  Image.asset(
                                    'assets/icons/add-user.png',
                                    height: 20,
                                    width: 20,
                                    color: AppColor.whiteColor,
                                  ),
                                  Text(
                                    'Send Request',
                                    style: TextConst.headingStyle(
                                        12, AppColor.whiteColor),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Container(
                              height: 60,
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: AppColor.whiteColor,
                                border: Border.all(color: AppColor.redColor),
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
                                    'Follow',
                                    style: TextConst.headingStyle(
                                        12, AppColor.redColor),
                                  ),
                                ],
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
                                  border: Border.all(color: AppColor.redColor),
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
                            '${widget.user.friends!.length}\nFriends',
                            textAlign: TextAlign.center,
                            style:
                                TextConst.MediumStyle(16, AppColor.blackColor),
                          ),
                        ),
                        Center(
                          child: Text(
                            '${widget.user.followerCount!}\nFollowers',
                            textAlign: TextAlign.center,
                            style:
                                TextConst.MediumStyle(16, AppColor.blackColor),
                          ),
                        ),
                        Center(
                          child: Text(
                            '${widget.user.posts!.length}\nPosts',
                            textAlign: TextAlign.center,
                            style:
                                TextConst.MediumStyle(16, AppColor.blackColor),
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
                            .where((post) => post.uid == widget.user.uid)
                            .toList();

                        if (currentIdx == 0) {
                          return SizedBox(
                            height: 450,
                            child: Scrollbar(
                                child: postCardWidget(context, posts,
                                    widget.user, widget.user.uid.toString())),
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
                                      childAspectRatio: 1),
                              itemBuilder: (ctx, idx) {
                                // write code

                                return Container(
                                  margin: const EdgeInsets.all(10),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.network(
                                      images[idx],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        } else {
                          return getInformtion(
                              widget.user, context, widget.currentUid);
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
      ),
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
