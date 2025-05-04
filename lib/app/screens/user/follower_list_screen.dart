import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialseed/domain/entities/user_entity.dart';
import 'package:socialseed/features/services/theme_service.dart';

import '../../../data/models/user_model.dart';
import '../../../utils/constants/color_const.dart';
import '../../../utils/constants/firebase_const.dart';
import '../../../utils/constants/page_const.dart';
import '../../../utils/constants/tags_const.dart';
import '../../../utils/constants/text_const.dart';

class FollowerListScreen extends StatefulWidget {
  const FollowerListScreen({super.key, required this.user});

  final UserEntity user;

  @override
  State<FollowerListScreen> createState() => FollowerListScreenState();
}

class FollowerListScreenState extends State<FollowerListScreen> {
  List<UserEntity> followerList = [];

  Future<void> fetchFollower(String currentUid) async {
    try {
      final userCollection =
          FirebaseFirestore.instance.collection(FirebaseConst.users);

      final currentUserDoc = await userCollection.doc(currentUid).get();
      final List<dynamic> currentFollowers =
          currentUserDoc.data()?['followers'] ?? [];

      final List<UserModel> fetchedFollowers = [];
      for (String followerUid in currentFollowers) {
        final followerDoc = await userCollection.doc(followerUid).get();
        if (followerDoc.exists) {
          fetchedFollowers.add(UserModel.fromSnapShot(followerDoc));
        }
      }

      setState(() {
        followerList = fetchedFollowers;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching followers: $e');
      }
    }
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
  void initState() {
    super.initState();
    fetchFollower(widget.user.uid!);
  }

  @override
  Widget build(BuildContext context) {
    final bg = Provider.of<ThemeService>(context).isDarkMode
        ? AppColor.bgDark
        : AppColor.whiteColor;

    final textColor = Provider.of<ThemeService>(context).isDarkMode
        ? AppColor.whiteColor
        : AppColor.blackColor;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back_ios,
            color: textColor,
          ),
        ),
        backgroundColor: bg,
        title: Text('${widget.user.fullname} • Followers'),
        centerTitle: true,
      ),
      body: followerList.isEmpty
          ? Center(
              child: SizedBox(
                height: 200,
                width: double.infinity,
                child: Column(
                  children: [
                    Center(
                      child: Image.network(
                        'https://cdn-icons-png.flaticon.com/512/9896/9896874.png',
                        fit: BoxFit.cover,
                        height: 150,
                        width: 150,
                      ),
                    ),
                    Text(
                      "Don't Lose Hope Yet",
                      style: TextConst.headingStyle(17, textColor),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              itemBuilder: (ctx, idx) {
                final follower = followerList[idx];

                return Container(
                  margin: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage:
                            NetworkImage(follower.imageUrl.toString()),
                        radius: 30,
                      ),
                      sizeHor(10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                follower.fullname.toString(),
                                style: TextConst.headingStyle(16, textColor),
                              ),
                              sizeHor(10),
                              if (follower.work!.toLowerCase() != "none" &&
                                  widget.user.work!.toLowerCase() ==
                                      follower.work!.toLowerCase())
                                mutualTag("work"),
                              if (follower.school!.toLowerCase() != "none" &&
                                  widget.user.school!.toLowerCase() ==
                                      follower.school!.toLowerCase())
                                mutualTag("school"),
                              if (follower.college!.toLowerCase() != "none" &&
                                  widget.user.college!.toLowerCase() ==
                                      follower.college!.toLowerCase())
                                mutualTag("college"),
                              if (follower.location!.toLowerCase() != "none" &&
                                  widget.user.location!.toLowerCase() ==
                                      follower.location!.toLowerCase())
                                mutualTag("home"),
                            ],
                          ),
                          Text("@${follower.username}"),
                        ],
                      ),
                    ],
                  ),
                );
              },
              itemCount: followerList.length,
            ),
    );
  }
}
