import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialseed/app/cubits/get_single_user/get_single_user_cubit.dart';
import 'package:socialseed/app/screens/chat/chat_screen.dart';
import 'package:socialseed/app/screens/friend/friend_suggestion_screen.dart';
import 'package:socialseed/app/screens/post/feed_screen.dart';
import 'package:socialseed/app/screens/user/user_profile.dart';
import 'package:socialseed/utils/constants/asset_const.dart';
import 'package:socialseed/utils/constants/color_const.dart';

class HomeScreen extends StatefulWidget {
  final String uid;

  const HomeScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PageController _controller;

  @override
  void initState() {
    super.initState();

    _controller = PageController();
    // Fetch user data when the screen initializes
    BlocProvider.of<GetSingleUserCubit>(context)
        .getSingleUsers(uid: widget.uid);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<String> navIcons = [
    IconConst.homeIcon,
    IconConst.friendIcon,
    IconConst.chatIcon,
    IconConst.bellIcon,
    IconConst.userIcon,
  ];

  int currentIdx = 0;

  Widget navItem(String icon, int selectedIdx) {
    return GestureDetector(
      onTap: () {
        setState(() {
          currentIdx = selectedIdx;
        });

        _controller.jumpToPage(selectedIdx);
      },
      child: Container(
        height: 60,
        width: 60,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(45),
          color: (currentIdx == selectedIdx)
              ? AppColor.redColor
              : AppColor.whiteColor,
        ),
        child: Image.asset(
          icon,
          color: !(currentIdx == selectedIdx)
              ? AppColor.blackColor
              : AppColor.whiteColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: BlocBuilder<GetSingleUserCubit, GetSingleUserState>(
                builder: (context, state) {
                  if (state is GetSingleUsersLoaded) {
                    final currentUser = state.user;

                    List<Widget> screens = [
                      FeedScreen(user: currentUser),
                      FriendSuggestion(user: currentUser),
                      ChatScreen(user: currentUser),
                      const Center(child: Text('Notfication')),
                      UserProfile(
                        otherUid: currentUser.uid.toString(),
                      ),
                    ];

                    return PageView(
                      controller: _controller,
                      onPageChanged: (val) {
                        setState(() {
                          currentIdx = val;
                        });
                      },
                      children: screens,
                    );
                  } else if (state is GetSingleUsersLoading) {
                    return const Center(
                      child:
                          CircularProgressIndicator(), // Show loading indicator
                    );
                  } else {
                    return const Center(
                      child: Text(
                          'Failed to load user data'), // Show error message
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 80,
        width: double.infinity,
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColor.textGreyColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            navItem(navIcons[0], 0),
            navItem(navIcons[1], 1),
            navItem(navIcons[2], 2),
            navItem(navIcons[3], 3),
            navItem(navIcons[4], 4),
          ],
        ),
      ),
    );
  }
}
