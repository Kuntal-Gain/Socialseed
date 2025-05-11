import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:socialseed/data/models/story_model.dart';
import 'package:socialseed/data/models/user_model.dart';

import '../../../domain/entities/story_entity.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../utils/constants/color_const.dart';
import '../../../utils/constants/firebase_const.dart';
import 'story_ui.dart';

class StoryScreen extends StatefulWidget {
  final String userId;
  final UserEntity curruser;

  const StoryScreen({
    super.key,
    required this.userId,
    required this.curruser,
  });

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  List<StoryEntity> stories = [];
  bool isLoading = true;
  UserEntity? user;

  @override
  void initState() {
    super.initState();
    loadStories(); // Changed to call new combined function
    getUserByIdFromUID();
  }

  Future<void> loadStories() async {
    try {
      final userDoc = FirebaseFirestore.instance
          .collection(FirebaseConst.users)
          .doc(widget.userId);

      final docSnapshot = await userDoc.get();
      if (docSnapshot.exists) {
        final List<dynamic> storyIds = docSnapshot.get("stories") ?? [];

        // Ensure the list contains only Strings (story IDs)
        final List<String> validStoryIds =
            storyIds.whereType<String>().toList();

        if (validStoryIds.isNotEmpty) {
          // Fetch all stories in parallel
          final List<DocumentSnapshot> storySnapshots = await Future.wait(
            validStoryIds.map((id) => FirebaseFirestore.instance
                .collection(FirebaseConst
                    .story) // Adjust to your actual collection name
                .doc(id)
                .get()),
          );

          // Convert documents to StoryModel objects
          stories = storySnapshots
              .where(
                  (snap) => snap.exists) // Remove null or non-existent stories
              .map((snap) => StoryModel.fromSnapshot(snap))
              .toList();

          // Filter out expired stories (older than 24 hours)
          final now = Timestamp.now().toDate();
          stories = stories.where((story) {
            final storyTime = story.createdAt.toDate();
            return now.difference(storyTime).inHours <= 24;
          }).toList();
        }

        if (kDebugMode) {
          print("Loaded ${stories.length} stories for user ${widget.userId}");
        }
      } else {
        if (kDebugMode) {
          print("No stories found for user ${widget.userId}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error loading stories: $e");
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<UserEntity?> getUserById(String userId) async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection(FirebaseConst.users)
          .doc(userId)
          .get();

      if (docSnapshot.exists) {
        return UserModel.fromSnapShot(docSnapshot);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching user by ID: $e");
      }
    }
    return null;
  }

  void getUserByIdFromUID() async {
    final storyUser = await getUserById(widget.userId);

    setState(() {
      user = storyUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body:
            Center(child: CircularProgressIndicator(color: AppColor.redColor)),
      );
    }

    if (stories.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
            child: Text("No Story Available",
                style: TextStyle(color: Colors.white))),
      );
    }

    return StoryUI(
        stories: stories, // Show the first story (You can modify this)
        storyUser: user!,
        curruser: widget.curruser);
  }
}
