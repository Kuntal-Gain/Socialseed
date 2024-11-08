import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialseed/app/cubits/get_single_user/get_single_user_cubit.dart';
import 'package:socialseed/app/cubits/users/user_cubit.dart';
import 'package:socialseed/app/screens/chat/chat_screen.dart';
import 'package:socialseed/app/screens/friend/friend_suggestion_screen.dart';
import 'package:socialseed/app/screens/notification/notification_screen.dart';
import 'package:socialseed/app/screens/post/feed_screen.dart';
import 'package:socialseed/app/screens/user/user_profile.dart';
import 'package:socialseed/utils/constants/asset_const.dart';
import 'package:socialseed/utils/constants/color_const.dart';
import 'package:socialseed/dependency_injection.dart' as di;

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

    // Initialize PageController with initialPage
    _controller = PageController(initialPage: 0);
    BlocProvider.of<GetSingleUserCubit>(context)
        .getSingleUsers(uid: widget.uid);

    di.sl<UserCubit>().updateStatus(uid: widget.uid, isOnline: true);

    SystemChannels.lifecycle.setMessageHandler((message) async {
      if (kDebugMode) {
        print(message);
      }

      if (message == AppLifecycleState.paused.toString()) {
        di.sl<UserCubit>().updateStatus(uid: widget.uid, isOnline: false);
      } else if (message == AppLifecycleState.resumed.toString()) {
        di.sl<UserCubit>().updateStatus(uid: widget.uid, isOnline: true);
      }

      return Future.value(message);
    });
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
        height: 50,
        width: 50,
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
      backgroundColor: Colors.white,
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
                      NotificationScreen(uid: currentUser.uid!),
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
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return const Center(
                      child: Text('Failed to load user data'),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 70,
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
