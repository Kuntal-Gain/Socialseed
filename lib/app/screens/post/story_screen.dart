import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:socialseed/app/screens/home_screen.dart';
import 'package:socialseed/domain/entities/story_entity.dart';
import 'package:socialseed/domain/entities/user_entity.dart';
import 'package:socialseed/utils/constants/color_const.dart';
import 'package:socialseed/utils/constants/page_const.dart';
import 'package:socialseed/utils/constants/tags_const.dart';
import 'package:socialseed/utils/constants/text_const.dart';

import '../../../data/models/user_model.dart';
import '../../../utils/constants/firebase_const.dart';

class StoryScreen extends StatefulWidget {
  final StoryEntity story;
  final UserEntity curruser;
  final UserEntity storyUser;
  const StoryScreen({
    super.key,
    required this.story,
    required this.curruser,
    required this.storyUser,
  });

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  List stories = [];

  @override
  void initState() {
    stories = widget.story.viewers
        .where((viewer) => viewer != widget.curruser.uid!)
        .toList();

    super.initState();
  }

  Future<UserEntity?> getUserByUid(String uid) async {
    final userCollection =
        FirebaseFirestore.instance.collection(FirebaseConst.users);

    try {
      final DocumentSnapshot doc = await userCollection.doc(uid).get();
      if (doc.exists) {
        return UserModel.fromSnapShot(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        // Navigate to HomeScreen instead of allowing system back
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (ctx) => HomeScreen(uid: widget.curruser.uid!)));
        return false; // Prevents default back button behavior
      },
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 24, 17, 17),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: 80,
                width: double.infinity,
                child: Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (ctx) =>
                                      HomeScreen(uid: widget.curruser.uid!)));
                        },
                        icon: const Icon(Icons.arrow_back_ios)),
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
                                    if (widget.storyUser.school!
                                                .toLowerCase() !=
                                            "none" &&
                                        widget.storyUser.school!
                                                .toLowerCase() ==
                                            widget.curruser.school!
                                                .toLowerCase())
                                      mutualTag("school"),
                                    if (widget.storyUser.college!
                                                .toLowerCase() !=
                                            "none" &&
                                        widget.storyUser.college!
                                                .toLowerCase() ==
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
              SizedBox(
                height: 500,
                width: double.infinity,
                child: Image.network(
                  widget.story.storyData,
                  fit: BoxFit.cover,
                ),
              ),
              if (widget.story.userId == widget.curruser.uid)
                Column(
                  children: [
                    Text(
                      widget.story.content,
                      style: TextConst.MediumStyle(
                        20,
                        AppColor.whiteColor,
                      ),
                    ),
                    sizeVar(10),
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled:
                              true, // If you want a full-screen bottom sheet
                          backgroundColor: Colors
                              .transparent, // You can set background color
                          builder: (context) {
                            return Container(
                                height: stories.isEmpty
                                    ? size.height * 0.1
                                    : size.height *
                                        0.15 *
                                        stories
                                            .length, // Height of the bottom sheet (40% of screen)
                                decoration: const BoxDecoration(
                                  color: Colors
                                      .white, // You can customize the color
                                  borderRadius: BorderRadius.only(
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
                                          '${stories.length} Views',
                                          style: TextConst.headingStyle(
                                            16,
                                            AppColor.whiteColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                        child: ListView.builder(
                                      itemCount: stories.length,
                                      itemBuilder: (ctx, idx) {
                                        return FutureBuilder<UserEntity?>(
                                          future: getUserByUid(
                                              stories[idx]), // Fetch the vie
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return const Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                color: AppColor.redColor,
                                              )); // Show a loader while fetching
                                            }

                                            if (snapshot.hasError ||
                                                !snapshot.hasData) {
                                              return const Text(
                                                  'Error loading viewer'); // Handle error case
                                            }

                                            // Successfully fetched viewer
                                            final viewer = snapshot.data;

                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(12.0),
                                              child: Row(
                                                children: [
                                                  ClipOval(
                                                    child: Image.network(
                                                      viewer!.imageUrl!,
                                                      height: size.height *
                                                          0.05, // Set equal height and width
                                                      width: size.height *
                                                          0.05, // Same value as height for a circle
                                                      fit: BoxFit
                                                          .cover, // Ensures the image covers the container without distortion
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                      width:
                                                          10), // Add spacing between image and text
                                                  Text(
                                                    viewer.username.toString(),
                                                    style:
                                                        TextConst.headingStyle(
                                                      18,
                                                      AppColor.redColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                            // Display the viewer's data (adjust based on your model)
                                          },
                                        );
                                      },
                                    ))
                                  ],
                                ));
                          },
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Icon(
                            Icons.remove_red_eye,
                            color: AppColor.whiteColor,
                            size: 25,
                          ),
                          sizeHor(10),
                          Text(
                            stories.length.toString(),
                            style: TextConst.MediumStyle(
                              20,
                              AppColor.whiteColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
