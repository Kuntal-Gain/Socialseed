import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socialseed/core/services/route_generator.dart';
import 'package:socialseed/features/auth_module/model/user_model.dart';
import 'package:socialseed/features/auth_module/ui/provider/auth_provider.dart';
import 'package:socialseed/features/auth_module/ui/provider/creds_provider.dart';
import 'package:socialseed/features/feed/ui/explore_feed_screen.dart';
import 'package:socialseed/features/feed/ui/feed_screen.dart';
import 'package:socialseed/features/friends_module/ui/friends_suggestion_screen.dart';
import 'package:socialseed/features/home/ui/widget/navbar.dart';
import 'package:socialseed/features/notifications/ui/notification_screen.dart';
import 'package:socialseed/features/profile/ui/profile_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _index = 0;

  List<Widget> pages = [
    const FeedScreen(),
    FriendRequestsScreen(),
    ExploreFeedScreen(),
    NotificationsScreen(),
    const UserProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final uidAsync = ref.watch(getCurrentUserProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      body: uidAsync.when(
        // data: (data) => Column(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     Center(child: Text(data.toString())),
        //     ElevatedButton(
        //       onPressed: () {
        //         ref.read(authFormProvider.notifier).logout();

        //         Navigator.of(context).pushNamedAndRemoveUntil(
        //           RouteGenerator.kSplash,
        //           (route) => false,
        //         );
        //       },
        //       child: const Text("Logout"),
        //     )
        //   ],
        // ),
        data: (data) => IndexedStack(
          index: _index,
          children: pages,
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Text(error.toString()),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (user?.userType == UserType.admin)
            Container(
              height: 40,
              width: double.infinity,
              color: Colors.red, // your strip
              child: const Center(
                  child: Text(
                "You Are a Admin",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              )),
            ),
          SocialBottomNav(
            currentIndex: _index,
            onTap: (index) => setState(() => _index = index),
          ),
        ],
      ),
    );
  }
}
