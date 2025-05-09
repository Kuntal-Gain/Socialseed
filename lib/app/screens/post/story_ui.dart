import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialseed/domain/entities/story_entity.dart';
import 'package:socialseed/domain/entities/user_entity.dart';
import 'package:socialseed/features/services/theme_service.dart';
import 'package:socialseed/utils/constants/color_const.dart';
import 'package:socialseed/utils/constants/text_const.dart';
import 'package:socialseed/app/screens/home_screen.dart';

import '../../../data/models/user_model.dart';
import '../../../utils/constants/tags_const.dart';

class StoryUI extends StatefulWidget {
  final List<StoryEntity> stories; // Now supports multiple stories
  final UserEntity curruser;
  final UserEntity storyUser;

  const StoryUI({
    super.key,
    required this.stories,
    required this.curruser,
    required this.storyUser,
  });

  @override
  State<StoryUI> createState() => _StoryUIState();
}

class _StoryUIState extends State<StoryUI> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 24, 17, 17),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Story Progress Indicators
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: List.generate(
                  widget.stories.length,
                  (index) => Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 2, vertical: 8),
                      decoration: BoxDecoration(
                        color: index == _currentPage
                            ? AppColor.redColor
                            : AppColor.redColor.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Top bar with user info
            SizedBox(
              height: 80,
              width: double.infinity,
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (ctx) =>
                                HomeScreen(uid: widget.curruser.uid!)));
                      },
                      icon: const Icon(Icons.arrow_back_ios,
                          color: Colors.white)),
                  CircleAvatar(
                    radius: 27,
                    backgroundImage: NetworkImage(widget.storyUser.imageUrl!),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.storyUser.fullname!,
                              style: TextConst.headingStyle(
                                16,
                                AppColor.whiteColor,
                              ),
                            ),
                            if (widget.storyUser.isVerified!)
                              Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Image.asset(
                                  'assets/3963-verified-developer-badge-red 1.png',
                                  height: 18,
                                  width: 18,
                                ),
                              ),
                          ],
                        ),
                        (widget.curruser.uid! != widget.storyUser.uid)
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (widget.storyUser.work!.toLowerCase() !=
                                          "none" &&
                                      widget.storyUser.work!.toLowerCase() ==
                                          widget.curruser.work!.toLowerCase())
                                    mutualTag("work"),
                                  if (widget.storyUser.school!.toLowerCase() !=
                                          "none" &&
                                      widget.storyUser.school!.toLowerCase() ==
                                          widget.curruser.school!.toLowerCase())
                                    mutualTag("school"),
                                  if (widget.storyUser.college!.toLowerCase() !=
                                          "none" &&
                                      widget.storyUser.college!.toLowerCase() ==
                                          widget.curruser.college!
                                              .toLowerCase())
                                    mutualTag("college"),
                                  if (widget.storyUser.location!
                                              .toLowerCase() !=
                                          "none" &&
                                      widget.storyUser.location!
                                              .toLowerCase() ==
                                          widget.curruser.location!
                                              .toLowerCase())
                                    mutualTag("home"),
                                ],
                              )
                            : mutualTag("You"),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // PageView for Multiple Stories
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.stories.length,
                onPageChanged: (index) {
                  setState(() {}); // Update UI on page change
                },
                itemBuilder: (context, index) {
                  final story = widget.stories[index];

                  return Stack(
                    children: [
                      Center(
                        child: Image.network(
                          story.storyData,
                          fit: BoxFit.cover,
                          height: double.infinity,
                          width: double.infinity,
                        ),
                      ),
                      Positioned(
                        bottom: 50,
                        left: 20,
                        right: 20,
                        child: Center(
                          child: Text(
                            story.content,
                            style: TextConst.MediumStyle(
                              20,
                              AppColor.whiteColor,
                            ),
                          ),
                        ),
                      ),
                      if (story.userId == widget.curruser.uid)
                        Positioned(
                          bottom: 10,
                          left: 20,
                          right: 20,
                          child: GestureDetector(
                            onTap: () {
                              _showViewersModal(context, story.viewers, size);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                const Icon(
                                  Icons.remove_red_eye,
                                  color: AppColor.whiteColor,
                                  size: 25,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  story.viewers.length.toString(),
                                  style: TextConst.MediumStyle(
                                    20,
                                    AppColor.whiteColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to Show Viewers Modal
  void _showViewersModal(BuildContext context, List viewers, Size size) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: viewers.isEmpty
              ? size.height * 0.1
              : size.height * 0.15 * viewers.length,
          decoration: BoxDecoration(
            color: Provider.of<ThemeService>(context).isDarkMode
                ? AppColor.bgDark
                : AppColor.whiteColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Container(
                height: 60,
                width: double.infinity,
                margin: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: AppColor.redColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Center(
                  child: Text(
                    '${viewers.length} Views',
                    style: TextConst.headingStyle(
                      16,
                      AppColor.whiteColor,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: viewers.length,
                  itemBuilder: (ctx, idx) {
                    return FutureBuilder<UserEntity?>(
                      future: getUserByUid(viewers[idx]),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator(
                            color: AppColor.redColor,
                          ));
                        }

                        if (snapshot.hasError || !snapshot.hasData) {
                          return const Text('Error loading viewer');
                        }

                        final viewer = snapshot.data;

                        return Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              ClipOval(
                                child: Image.network(
                                  viewer!.imageUrl!,
                                  height: size.height * 0.05,
                                  width: size.height * 0.05,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                viewer.username.toString(),
                                style: TextConst.headingStyle(
                                  18,
                                  AppColor.redColor,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              )
            ],
          ),
        );
      },
    );
  }

  // Fetch user by UID (Consider moving this to a separate service)
  Future<UserEntity?> getUserByUid(String uid) async {
    final userCollection = FirebaseFirestore.instance.collection('users');

    try {
      final doc = await userCollection.doc(uid).get();
      if (doc.exists) {
        return UserModel.fromSnapShot(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
