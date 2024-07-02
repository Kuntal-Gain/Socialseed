import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialseed/app/cubits/users/user_cubit.dart';
import 'package:socialseed/app/screens/user/other_user_profile.dart';
import 'package:socialseed/domain/entities/user_entity.dart';
import 'package:socialseed/utils/constants/color_const.dart';
import 'package:socialseed/utils/constants/firebase_const.dart';
import 'package:socialseed/utils/constants/text_const.dart';
import '../../../data/models/user_model.dart';

class FriendSuggestion extends StatefulWidget {
  final UserEntity user;
  const FriendSuggestion({super.key, required this.user});

  @override
  State<FriendSuggestion> createState() => _FriendSuggestionState();
}

class _FriendSuggestionState extends State<FriendSuggestion> {
  List<UserEntity> requests = [];
  List<UserModel> suggestion = [];
  String currentUid = '';

  @override
  void initState() {
    super.initState();
    fetchRequests();
    fetchSuggestions();
    currentUid = FirebaseAuth.instance.currentUser!.uid;
  }

  Future<void> fetchRequests() async {
    try {
      final userCollection =
          FirebaseFirestore.instance.collection(FirebaseConst.users);
      final currentUid = FirebaseAuth.instance.currentUser!.uid;
      final currentUserRef = userCollection.doc(currentUid);
      final currentUserDoc = await currentUserRef.get();

      if (currentUserDoc.exists) {
        List<String> requestsUids =
            List<String>.from(currentUserDoc.data()?['requests'] ?? []);

        final List<UserModel> fetchedRequests = [];
        for (final requestUid in requestsUids) {
          final requestUserRef = userCollection.doc(requestUid);
          final requestUserDoc = await requestUserRef.get();
          if (requestUserDoc.exists) {
            fetchedRequests.add(UserModel.fromSnapShot(requestUserDoc));
          }
        }

        setState(() {
          requests = fetchedRequests;
        });
      } else {}
      // ignore: empty_catches
    } catch (e) {}
  }

  Future<void> fetchSuggestions() async {
    try {
      final userCollection =
          FirebaseFirestore.instance.collection(FirebaseConst.users);
      final querySnapshot = await userCollection.get();

      final List<UserModel> fetchedSuggestions = querySnapshot.docs
          .map((doc) => UserModel.fromSnapShot(doc))
          .where((user) => user.uid != currentUid) // Filter out current user
          .toList();

      setState(() {
        suggestion = fetchedSuggestions;
      });
      // ignore: empty_catches
    } catch (e) {}
  }

  Widget suggestionCard(UserEntity user) {
    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.greyShadowColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundImage: NetworkImage(user.imageUrl != null &&
                    user.imageUrl!.isNotEmpty
                ? user.imageUrl!
                : 'https://static.vecteezy.com/system/resources/thumbnails/005/545/335/small/user-sign-icon-person-symbol-human-avatar-isolated-on-white-backogrund-vector.jpg'),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                user.fullname!,
                style: TextConst.headingStyle(
                  16,
                  AppColor.blackColor,
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => BlocProvider.of<UserCubit>(context)
                        .sendRequest(user: user),
                    child: Container(
                      height: 40,
                      width: 100,
                      decoration: BoxDecoration(
                        color: AppColor.redColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          (user.requests!.contains(currentUid))
                              ? 'Cancel'
                              : 'Add Friend',
                          style: TextConst.headingStyle(
                            14,
                            AppColor.whiteColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) =>
                              OtherUserProfile(otherUid: user.uid!),
                        ),
                      );
                    },
                    child: Container(
                      height: 40,
                      width: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColor.greyShadowColor),
                        color: AppColor.whiteColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          'View Profile',
                          style: TextConst.headingStyle(
                            14,
                            AppColor.blackColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget requestCard(UserEntity user) {
    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.greyShadowColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundImage: NetworkImage(user.imageUrl != null &&
                    user.imageUrl!.isNotEmpty
                ? user.imageUrl!
                : 'https://static.vecteezy.com/system/resources/thumbnails/005/545/335/small/user-sign-icon-person-symbol-human-avatar-isolated-on-white-backogrund-vector.jpg'),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                user.fullname!,
                style: TextConst.headingStyle(
                  16,
                  AppColor.blackColor,
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      BlocProvider.of<UserCubit>(context)
                          .acceptRequest(user: user)
                          .then((value) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.green,
                            content: Text('Request Accepted'),
                          ),
                        );
                      });
                    },
                    child: Container(
                      height: 40,
                      width: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColor.greyShadowColor),
                        color: AppColor.whiteColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          'Accept',
                          style: TextConst.headingStyle(
                            14,
                            AppColor.blackColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: () => BlocProvider.of<UserCubit>(context)
                        .rejectRequest(user: user),
                    child: Container(
                      height: 40,
                      width: 100,
                      decoration: BoxDecoration(
                        color: AppColor.redColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          'Reject',
                          style: TextConst.headingStyle(
                            14,
                            AppColor.whiteColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (requests.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                'Friend Requests',
                style: TextConst.headingStyle(
                  21,
                  AppColor.blackColor,
                ),
              ),
            ),
          if (requests.isNotEmpty)
            SizedBox(
              height: 120, // Adjust the height to your needs
              child: ListView.builder(
                itemCount: requests.length,
                itemBuilder: (ctx, idx) {
                  final user = requests[idx];
                  return requestCard(user);
                },
              ),
            ),
          if (suggestion.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                'Find Friends',
                style: TextConst.headingStyle(
                  21,
                  AppColor.blackColor,
                ),
              ),
            ),
          Expanded(
            child: suggestion.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: suggestion.length,
                    itemBuilder: (ctx, idx) {
                      final user = suggestion[idx];
                      return suggestionCard(user);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
