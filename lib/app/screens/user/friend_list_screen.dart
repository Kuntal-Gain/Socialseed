import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:socialseed/app/screens/user/user_profile.dart';
import 'package:socialseed/domain/entities/user_entity.dart';

import '../../../data/models/user_model.dart';
import '../../../utils/constants/color_const.dart';
import '../../../utils/constants/firebase_const.dart';
import '../../../utils/constants/page_const.dart';
import '../../../utils/constants/tags_const.dart';
import '../../../utils/constants/text_const.dart';

class FriendListScreen extends StatefulWidget {
  const FriendListScreen({super.key, required this.user});

  final UserEntity user;

  @override
  State<FriendListScreen> createState() => _FriendListScreenState();
}

class _FriendListScreenState extends State<FriendListScreen> {
  List<UserEntity> friendList = [];

  Future<void> fetchFriends(String currentUid) async {
    try {
      final userCollection =
          FirebaseFirestore.instance.collection(FirebaseConst.users);

      final currentUserDoc = await userCollection.doc(currentUid).get();
      final List<dynamic> currentFriends =
          currentUserDoc.data()?['friends'] ?? [];

      final List<UserModel> fetchedFriends = [];
      for (String friendUid in currentFriends) {
        final friendDoc = await userCollection.doc(friendUid).get();
        if (friendDoc.exists) {
          fetchedFriends.add(UserModel.fromSnapShot(friendDoc));
        }
      }

      setState(() {
        friendList = fetchedFriends;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching friends: $e');
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
    fetchFriends(widget.user.uid!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('${widget.user.fullname} • Friends'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemBuilder: (ctx, idx) {
          final friend = friendList[idx];

          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => UserProfile(otherUid: friend.uid!)));
            },
            child: Container(
              margin: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(friend.imageUrl.toString()),
                    radius: 30,
                  ),
                  sizeHor(10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            friend.fullname.toString(),
                            style:
                                TextConst.headingStyle(16, AppColor.blackColor),
                          ),
                          sizeHor(10),
                          if (friend.work!.toLowerCase() != "none" &&
                              widget.user.work!.toLowerCase() ==
                                  friend.work!.toLowerCase())
                            mutualTag("work"),
                          if (friend.school!.toLowerCase() != "none" &&
                              widget.user.school!.toLowerCase() ==
                                  friend.school!.toLowerCase())
                            mutualTag("school"),
                          if (friend.college!.toLowerCase() != "none" &&
                              widget.user.college!.toLowerCase() ==
                                  friend.college!.toLowerCase())
                            mutualTag("college"),
                          if (friend.location!.toLowerCase() != "none" &&
                              widget.user.location!.toLowerCase() ==
                                  friend.location!.toLowerCase())
                            mutualTag("home"),
                        ],
                      ),
                      Text("@${friend.username}"),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
        itemCount: friendList.length,
      ),
    );
  }
}
