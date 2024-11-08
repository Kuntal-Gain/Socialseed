import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:socialseed/app/cubits/users/user_cubit.dart';
import 'package:socialseed/app/screens/user/user_profile.dart';
import 'package:socialseed/domain/entities/user_entity.dart';
import 'package:socialseed/utils/constants/color_const.dart';
import 'package:socialseed/utils/constants/firebase_const.dart';
import 'package:socialseed/utils/constants/page_const.dart';
import 'package:socialseed/utils/constants/text_const.dart';
import 'package:socialseed/utils/custom/custom_snackbar.dart';
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
    currentUid = FirebaseAuth.instance.currentUser!.uid;
    // Set up Firestore listeners
    fetchRequests();
    fetchSuggestions(currentUid);
  }

  // Listen for real-time updates to requests
  void fetchRequests() {
    final userCollection =
        FirebaseFirestore.instance.collection(FirebaseConst.users);
    final currentUserRef = userCollection.doc(currentUid);

    currentUserRef.snapshots().listen((currentUserDoc) {
      if (currentUserDoc.exists) {
        List<String> requestsUids =
            List<String>.from(currentUserDoc.data()?['requests'] ?? []);
        _fetchRequestUsers(requestsUids);
      }
    });
  }

  // Fetch user entities based on UIDs
  Future<void> _fetchRequestUsers(List<String> requestsUids) async {
    final userCollection =
        FirebaseFirestore.instance.collection(FirebaseConst.users);
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
  }

  // Listen for real-time updates to suggestions
  void fetchSuggestions(String currentUid) {
    final userCollection = FirebaseFirestore.instance.collection('users');

    userCollection.snapshots().listen((querySnapshot) {
      // Fetch current user's friends
      userCollection.doc(currentUid).get().then((currentUserDoc) {
        final List<dynamic> currentFriends =
            currentUserDoc.data()!['friends'] ?? [];
        final List<UserModel> fetchedSuggestions = querySnapshot.docs
            .map((doc) => UserModel.fromSnapShot(doc))
            .where((user) =>
                user.uid != currentUid && !currentFriends.contains(user.uid))
            .toList();

        setState(() {
          suggestion = fetchedSuggestions;
        });
      });
    });
  }

  Widget suggestionCard(UserEntity otherUser, UserEntity currentUser) {
    return Container(
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
            radius: 32, // Fixed size for avatar, can adjust if needed
            backgroundImage: NetworkImage(otherUser.imageUrl != null &&
                    otherUser.imageUrl!.isNotEmpty
                ? otherUser.imageUrl!
                : 'https://static.vecteezy.com/system/resources/thumbnails/005/545/335/small/user-sign-icon-person-symbol-human-avatar-isolated-on-white-backogrund-vector.jpg'),
          ),
          const SizedBox(width: 10),
          Expanded(
            // Allow to take up available space
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      // Make the text flexible
                      child: Row(
                        children: [
                          Text(
                            otherUser.fullname!,
                            style: TextConst.headingStyle(
                              16,
                              AppColor.blackColor,
                            ),
                            overflow: TextOverflow.ellipsis, // Prevent overflow
                          ),
                          sizeHor(5),
                          if (otherUser.isVerified!)
                            Image.asset(
                                'assets/3963-verified-developer-badge-red 1.png')
                        ],
                      ),
                    ),
                    // Your mutual tags logic
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => BlocProvider.of<UserCubit>(context)
                            .sendRequest(user: otherUser),
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColor.redColor,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              (otherUser.requests!.contains(currentUid))
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
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) =>
                                  UserProfile(otherUid: otherUser.uid!),
                            ),
                          );
                        },
                        child: Container(
                          height: 40,
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
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget requestCard(UserEntity user) {
    return Container(
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
          Expanded(
            // Use Expanded for the column
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          BlocProvider.of<UserCubit>(context)
                              .acceptRequest(user: user)
                              .then((value) {
                            // ignore: use_build_context_synchronously
                            successBar(context, "Request Accepted");
                          });
                        },
                        child: Container(
                          height: 40,
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
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => BlocProvider.of<UserCubit>(context)
                            .rejectRequest(user: user),
                        child: Container(
                          height: 40,
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
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: (suggestion.isEmpty && requests.isEmpty)
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Lottie.asset('assets/animations/friends.json'),
                Center(
                  child: Text(
                    'No Friend Suggestions \ncurrently now',
                    style: TextConst.headingStyle(20, AppColor.blackColor),
                  ),
                ),
              ],
            )
          : SingleChildScrollView(
              // Allow scrolling for overflow
              child: Column(
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
                      height: 120, // This can be changed if needed
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
                  ListView.builder(
                    itemCount: suggestion.length,
                    physics:
                        const NeverScrollableScrollPhysics(), // Prevent scrolling conflict
                    shrinkWrap: true, // Adjust height to fit content
                    itemBuilder: (ctx, idx) {
                      final user = suggestion[idx];
                      return suggestionCard(user, widget.user);
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
