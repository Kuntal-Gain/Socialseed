import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socialseed/core/services/route_generator.dart';
import 'package:socialseed/features/auth_module/ui/provider/auth_provider.dart';
import 'package:socialseed/features/feed/ui/feed_screen.dart';
import 'package:socialseed/features/home/ui/widget/navbar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _index = 0;

  List<Widget> pages = [
    const FeedScreen(),
    Center(child: Text("Friends")),
    Center(child: Text("Explore")),
    Center(child: Text("Notifications")),
    Center(child: Text("Profile")),
  ];

  @override
  Widget build(BuildContext context) {
    final uidAsync = ref.watch(getCurrentUserProvider);

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
      bottomNavigationBar: SocialBottomNav(
        currentIndex: _index,
        onTap: (index) => setState(() => _index = index),
      ),
    );
  }
}
