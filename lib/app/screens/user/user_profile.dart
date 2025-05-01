// ignore_for_file: use_build_context_synchronously, duplicate_ignore

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:socialseed/app/cubits/post/post_cubit.dart';
import 'package:socialseed/app/cubits/users/user_cubit.dart';
import 'package:socialseed/app/screens/chat/message_screen.dart';
import 'package:socialseed/app/screens/settings/settings_screen.dart';
import 'package:socialseed/app/screens/user/friend_list_screen.dart';
import 'package:socialseed/app/screens/user/milestone_screen.dart';
import 'package:socialseed/data/models/user_model.dart';
import 'package:socialseed/domain/entities/post_entity.dart';

import 'package:socialseed/domain/entities/user_entity.dart';
import 'package:socialseed/domain/usecases/user/get_current_uid_usecase.dart';
import 'package:socialseed/utils/constants/color_const.dart';
import 'package:socialseed/utils/constants/firebase_const.dart';
import 'package:socialseed/utils/constants/page_const.dart';
import 'package:socialseed/utils/constants/text_const.dart';
import 'package:socialseed/utils/custom/custom_snackbar.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/entities/chat_entity.dart';
import '../../../features/services/theme_service.dart';
import '../../cubits/get_single_other_user/get_single_other_user_cubit.dart';
import '../../cubits/message/chat_id/chat_cubit.dart';
import '../../cubits/message/message_cubit.dart';
import '../../widgets/profile_widget.dart';
import 'package:socialseed/dependency_injection.dart' as di;

import '../../widgets/view_post_widget.dart';
import 'follower_list_screen.dart';

class UserProfile extends StatefulWidget {
  final String otherUid;
  const UserProfile({super.key, required this.otherUid});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile>
    with SingleTickerProviderStateMixin {
  late TabController _controller;

  int currentIdx = 0;
  List<String> images = [];
  String currentUid = FirebaseAuth.instance.currentUser!.uid;
  late UserEntity? currentUser;
  var selectedCoverImage = "";
  bool isPrivate = false;

  Future<String?> getExistingMessageId(
      String currentUid, String friendUid) async {
    final messageCollection =
        FirebaseFirestore.instance.collection(FirebaseConst.messages);

    // Query messages where the 'members' array contains the currentUid
    final query = await messageCollection
        .where('members', arrayContains: currentUid)
        .get();

    // Filter the documents to find one where 'members' also contains friendUid
    for (var doc in query.docs) {
      final members = List<String>.from(doc['members']);
      if (members.contains(friendUid)) {
        return doc.id; // Return the existing messageId if found
      }
    }
    return null; // Return null if no existing messageId is found
  }

  Future<void> fetchUser(String uid) async {
    final userCollection =
        FirebaseFirestore.instance.collection(FirebaseConst.users);

    try {
      final DocumentSnapshot doc = await userCollection.doc(uid).get();
      if (doc.exists) {
        setState(() {
          currentUser = UserModel.fromSnapShot(doc); // Update the user state
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user: $e');
      }
    }
  }

  Future<void> fetchPosts(String uid) async {
    // Step 1: Fetch the user's document from Firestore
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (userDoc.exists) {
      // Step 2: Get the list of post IDs from the user's document
      List<dynamic> postIds = userDoc.data()!['posts'];

      // Step 3: Fetch the post images for each post ID
      for (String postId in postIds) {
        final postDoc = await FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .get();

        if (postDoc.exists) {
          List<dynamic> postImages = postDoc.data()!['images'];
          setState(() {
            images.addAll(postImages.cast<String>());
          });
        }
      }
    }
  }

  Future<void> uploadCoverImage(String imagePath, String uid) async {
    // Define the storage reference
    final storageRef = FirebaseStorage.instance
        .ref('/profile/$uid/cover-image/${const Uuid().v1()}.jpg');

    try {
      // Upload the image
      await storageRef.putFile(File(imagePath));

      // Get the download URL
      String downloadURL = await storageRef.getDownloadURL();

      // Update Firestore with the new cover image URL
      await FirebaseFirestore.instance
          .collection(FirebaseConst.users)
          .doc(widget.otherUid)
          .update({
        'coverImage': downloadURL,
      });

      // Optionally, show a success message
    } catch (e) {
      // Optionally, show an error message to the user
    }
  }

  Future<bool> getPrivateStatus(String userId) async {
    try {
      // Reference to the user's document in the 'users' collection
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
          .instance
          .collection(FirebaseConst.users)
          .doc(userId)
          .get();

      // Check if the document exists
      if (userDoc.exists && userDoc.data() != null) {
        // Retrieve the 'isPrivate' field from the document
        bool isPrivate =
            userDoc.data()!['isPrivate'] ?? false; // default to false if null
        return isPrivate;
      } else {
        // If the document doesn't exist, return false (or handle as needed)
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching isPrivate status: $e");
      }
      return false; // Handle error cases by returning false
    }
  }

  Future<void> fetchStatus(String uid) async {
    var status = await getPrivateStatus(uid);

    setState(() {
      isPrivate = status;
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 3, vsync: this);
    BlocProvider.of<GetSingleOtherUserCubit>(context)
        .getSingleOtherUser(otherUid: widget.otherUid);
    BlocProvider.of<PostCubit>(context).getPosts(post: const PostEntity());

    di.sl<GetCurrentUidUsecase>().call().then((value) {
      setState(() {
        currentUid = value;
      });
    });

    fetchPosts(widget.otherUid);
    fetchUser(currentUid);
    fetchStatus(widget.otherUid);

    if (kDebugMode) {
      print(isPrivate);
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    final bg = Provider.of<ThemeService>(context).isDarkMode
        ? AppColor.bgDark
        : AppColor.whiteColor;

    final textColor = Provider.of<ThemeService>(context).isDarkMode
        ? AppColor.whiteColor
        : AppColor.blackColor;

    final tabShadow = Provider.of<ThemeService>(context).isDarkMode
        ? AppColor.secondaryDark
        : AppColor.greyShadowColor;

    return BlocBuilder<GetSingleOtherUserCubit, GetSingleOtherUserState>(
      builder: (ctx, state) {
        if (state is GetSingleOtherUserLoaded) {
          final user = state.otherUser;

          return Scaffold(
            backgroundColor: bg,
            appBar: AppBar(
              automaticallyImplyLeading:
                  widget.otherUid == currentUid ? false : true,
              centerTitle: true,
              surfaceTintColor: AppColor.bgDark,
              elevation: 0,
              backgroundColor: bg,
              title: Text('${user.fullname.toString()} • Profile',
                  style: TextStyle(color: textColor)),
              actions: [
                if (widget.otherUid == currentUid)
                  IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SettingsScreen(user: user),
                          ),
                        );
                      },
                      icon: const Icon(Icons.settings))
              ],
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        SizedBox(
                          height: 325,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (state.otherUser.coverImage != "")
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: ctx,
                                      builder: (_) => Dialog(
                                        backgroundColor: Colors.transparent,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              child: Image.network(
                                                state.otherUser.coverImage!,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(ctx).pop();
                                              },
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Container(
                                                      height:
                                                          size.height * 0.05,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            AppColor.redColor,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          "Close",
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize:
                                                                size.height *
                                                                    0.015,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),

                                                  if (widget.otherUid ==
                                                      currentUid) // Add spacing between buttons
                                                    Expanded(
                                                      child: GestureDetector(
                                                        onTap: () async {
                                                          // Allow current user to select a new cover image
                                                          final XFile? image =
                                                              await ImagePicker()
                                                                  .pickImage(
                                                            source: ImageSource
                                                                .gallery,
                                                            imageQuality: 80,
                                                          );

                                                          Navigator.of(ctx)
                                                              .pop();

                                                          if (image != null) {
                                                            setState(() {
                                                              selectedCoverImage =
                                                                  image.path;
                                                            });

                                                            // Generate a unique ID
                                                            await uploadCoverImage(
                                                                image.path,
                                                                widget
                                                                    .otherUid);
                                                          }
                                                        },
                                                        child: Container(
                                                          height: size.height *
                                                              0.05,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: AppColor
                                                                .redColor,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
                                                          ),
                                                          child: Center(
                                                            child: Text(
                                                              "Update",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize:
                                                                    size.height *
                                                                        0.015,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  const SizedBox(
                                                      width:
                                                          10), // Add spacing between buttons

                                                  if (widget.otherUid ==
                                                      currentUid)
                                                    Expanded(
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  FirebaseConst
                                                                      .users)
                                                              .doc(currentUid)
                                                              .update({
                                                            "coverImage": "",
                                                          });

                                                          Navigator.of(ctx)
                                                              .pop();
                                                        },
                                                        child: Container(
                                                          height: size.height *
                                                              0.05,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: AppColor
                                                                .redColor,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
                                                          ),
                                                          child: const Center(
                                                            child: Text(
                                                              "Delete",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    height: 140,
                                    width: double.infinity,
                                    margin: const EdgeInsets.all(12),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: CachedNetworkImage(
                                        imageUrl: state.otherUser.coverImage!,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),

                              if (state.otherUser.coverImage == "")
                                GestureDetector(
                                  onTap: () async {
                                    if (widget.otherUid == currentUid) {
                                      // Allow current user to select a new cover image
                                      final XFile? image =
                                          await ImagePicker().pickImage(
                                        source: ImageSource.gallery,
                                        imageQuality:
                                            80, // Adjust image quality if needed
                                      );

                                      if (image != null) {
                                        setState(() {
                                          selectedCoverImage = image.path;
                                        });

                                        // Generate a unique ID
                                        await uploadCoverImage(
                                            image.path, widget.otherUid);
                                      }
                                    }
                                  },
                                  child: Container(
                                    height: 140,
                                    width: double.infinity,
                                    margin: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColor.greyColor,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "No Cover Image",
                                        style: TextConst.headingStyle(
                                            16, AppColor.blackColor),
                                      ),
                                    ),
                                  ),
                                ),
                              // cover image

                              // profile data
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        user.fullname ??
                                            '', // Use empty string as default if fullname is null
                                        style: TextConst.headingStyle(
                                          18,
                                          textColor,
                                        ),
                                      ),
                                      sizeHor(10),
                                      if (user.isVerified!)
                                        Image.asset(
                                            'assets/3963-verified-developer-badge-red 1.png')
                                    ],
                                  ),
                                  Text(
                                    '@${user.username}',
                                    style:
                                        TextConst.headingStyle(16, textColor),
                                  ),
                                  Container(
                                    height: 30,
                                    width: 100,
                                    margin: const EdgeInsets.only(top: 5),
                                    decoration: BoxDecoration(
                                      color: (user.activeStatus ?? false)
                                          ? AppColor.redColor
                                          : AppColor.greyShadowColor,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Center(
                                      child: Text(
                                        (user.activeStatus ?? false)
                                            ? 'Online'
                                            : 'Offline',
                                        style: TextConst.headingStyle(
                                            14, AppColor.whiteColor),
                                      ),
                                    ),
                                  ),
                                  sizeVar(10),
                                  Text(
                                    user.bio.toString(),
                                    style: TextConst.RegularStyle(
                                        15, AppColor.blackColor),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 90,
                          left: 135,
                          right: 135,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: (user.activeStatus ?? false)
                                    ? AppColor.redColor
                                    : AppColor.greyShadowColor,
                                width: 5,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 55,
                              backgroundImage:
                                  NetworkImage(user.imageUrl.toString()),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (currentUid != user.uid)
                      Container(
                        height: 100,
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 15),
                        child: Row(
                          children: [
                            if (!user.friends!.contains(currentUid))
                              Expanded(
                                flex: 3,
                                child: GestureDetector(
                                  onTap: () {
                                    BlocProvider.of<UserCubit>(context)
                                        .sendRequestUsecase(user);
                                  },
                                  child: Container(
                                    height: 60,
                                    margin: const EdgeInsets.all(3),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColor.redColor,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        (!user.requests!.contains(currentUid))
                                            ? Image.asset(
                                                'assets/icons/add-user.png',
                                                height: 20,
                                                width: 20,
                                                color: AppColor.whiteColor,
                                              )
                                            : const Icon(
                                                Icons.cancel,
                                                color: Colors.white,
                                              ),
                                        Text(
                                          (!user.requests!.contains(currentUid))
                                              ? 'Send Request'
                                              : 'Cancel Request',
                                          style: TextConst.headingStyle(
                                              12, AppColor.whiteColor),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            if (user.friends!.contains(currentUid))
                              Expanded(
                                flex: 3,
                                child: GestureDetector(
                                  onTap: () {
                                    // toggle to remove friend
                                  },
                                  child: Container(
                                    height: 60,
                                    margin: const EdgeInsets.all(3),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColor.redColor,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          'assets/icons/check-mark.png',
                                          height: 20,
                                          width: 20,
                                          color: AppColor.whiteColor,
                                        ),
                                        sizeHor(10),
                                        Text(
                                          'Friend',
                                          style: TextConst.headingStyle(
                                              12, AppColor.whiteColor),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            Expanded(
                              flex: 2,
                              child: GestureDetector(
                                onTap: () async {
                                  if (user.followers!.contains(currentUid)) {
                                    await BlocProvider.of<UserCubit>(context)
                                        .unFollowUser(user: user);
                                    // Refresh only the current profile
                                    BlocProvider.of<GetSingleOtherUserCubit>(
                                            context)
                                        .getSingleOtherUser(
                                            otherUid: widget.otherUid);
                                  } else {
                                    await BlocProvider.of<UserCubit>(context)
                                        .followUser(user: user);
                                    // Refresh only the current profile
                                    BlocProvider.of<GetSingleOtherUserCubit>(
                                            context)
                                        .getSingleOtherUser(
                                            otherUid: widget.otherUid);
                                  }
                                },
                                child: Container(
                                  height: 60,
                                  padding: const EdgeInsets.all(12),
                                  margin: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: AppColor.whiteColor,
                                    border:
                                        Border.all(color: AppColor.redColor),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Image.asset(
                                        'assets/icons/followers.png',
                                        height: 20,
                                        width: 20,
                                        color: AppColor.redColor,
                                      ),
                                      Text(
                                        (user.followers!.contains(currentUid))
                                            ? 'UnFollow'
                                            : 'Follow',
                                        style: TextConst.headingStyle(
                                            12, AppColor.redColor),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: AspectRatio(
                                aspectRatio: 1 / 1,
                                child: GestureDetector(
                                  onTap: () async {
                                    final existingMessageId =
                                        await getExistingMessageId(
                                            currentUid, widget.otherUid);

                                    if (existingMessageId == null) {
                                      // Create a new chat
                                      final newMessageId = const Uuid().v4();
                                      // ignore: use_build_context_synchronously
                                      context.read<ChatCubit>().createMessageId(
                                            chat: ChatEntity(
                                              messageId: newMessageId,
                                              members: [
                                                widget.otherUid,
                                                currentUid
                                              ],
                                              lastMessage: "",
                                              isRead: false,
                                            ),
                                          );

                                      // Navigate to MessageScreen with newMessageId
                                      // ignore: use_build_context_synchronously
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (ctx) =>
                                              BlocProvider<MessageCubit>(
                                            create: (context) =>
                                                di.sl<MessageCubit>(),
                                            child: MessageScreen(
                                              sender: currentUser!,
                                              receiver: state.otherUser,
                                              messageId: newMessageId,
                                            ),
                                          ),
                                        ),
                                      );
                                    } else {
                                      // Navigate to MessageScreen with existingMessageId
                                      // ignore: use_build_context_synchronously
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (ctx) =>
                                              BlocProvider<MessageCubit>(
                                            create: (context) =>
                                                di.sl<MessageCubit>(),
                                            child: MessageScreen(
                                              sender: currentUser!,
                                              receiver: state.otherUser,
                                              messageId: existingMessageId,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    margin: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border:
                                          Border.all(color: AppColor.redColor),
                                    ),
                                    child: Image.asset(
                                      'assets/icons/messenger.png',
                                      height: 35,
                                      width: 35,
                                      color: AppColor.redColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Container(
                      margin: const EdgeInsets.all(16),
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Provider.of<ThemeService>(context).isDarkMode
                            ? AppColor.bgDark
                            : AppColor.whiteColor,
                        boxShadow: [
                          BoxShadow(
                            color: Provider.of<ThemeService>(context).isDarkMode
                                ? AppColor.blackColor
                                : AppColor.greyShadowColor,
                            blurRadius: 5,
                          ),
                        ],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) =>
                                        FriendListScreen(user: user))),
                            child: Center(
                              child: Text(
                                '${user.friends!.length}\nFriends',
                                textAlign: TextAlign.center,
                                style: TextConst.MediumStyle(16, textColor),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) =>
                                        FollowerListScreen(user: user))),
                            child: Center(
                              child: Text(
                                '${user.followerCount!}\nFollowers',
                                textAlign: TextAlign.center,
                                style: TextConst.MediumStyle(16, textColor),
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              '${user.posts!.length}\nPosts',
                              textAlign: TextAlign.center,
                              style: TextConst.MediumStyle(16, textColor),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // First condition: If the account is not private
                    if (!isPrivate ||
                        user.friends!.contains(currentUid) ||
                        currentUid == widget.otherUid) ...[
                      TabBar(
                        onTap: (val) {
                          setState(() {
                            currentIdx = val;
                          });
                        },
                        controller: _controller,
                        dividerHeight: 0,
                        indicatorColor: AppColor.redColor,
                        labelColor: AppColor.redColor,
                        overlayColor: WidgetStatePropertyAll(tabShadow),
                        tabs: const [
                          Text('Post'),
                          Text('Media'),
                          Text('About'),
                        ],
                      ),
                      sizeVar(20),

                      // Modify this BlocBuilder section
                      BlocBuilder<PostCubit, PostState>(
                        builder: (context, state) {
                          if (state is PostLoading) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: AppColor.redColor,
                              ),
                            );
                          }

                          if (state is PostLoaded) {
                            final posts = state.posts
                                .where((post) => post.uid == user.uid)
                                .toList();

                            if (currentIdx == 0) {
                              return PostCardWidget(
                                posts: posts,
                                user: user,
                                uid: user.uid.toString(),
                              );
                            } else if (currentIdx == 1) {
                              return posts.isEmpty
                                  ? const Center(child: Text("No Posts"))
                                  : GridView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: images.length,
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        mainAxisSpacing: 0,
                                        crossAxisSpacing: 0,
                                        childAspectRatio: 1,
                                      ),
                                      itemBuilder: (ctx, idx) {
                                        return GestureDetector(
                                          onTap: () {
                                            showDialog(
                                              context: ctx,
                                              builder: (_) => Dialog(
                                                backgroundColor:
                                                    Colors.transparent,
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                      child: Image.network(
                                                        images[idx],
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 10),
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(ctx).pop();
                                                      },
                                                      child: const Text(
                                                        "Close",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.all(10),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              child: CachedNetworkImage(
                                                imageUrl: images[idx],
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                            } else {
                              return getInformtion(user, context, currentUid);
                            }
                          }

                          if (state is PostFailure) {
                            failureBar(context, "Something Went wrong");
                          }

                          return const SizedBox();
                        },
                      ),
                    ]

// Second condition: If the account is private and the current user is not a friend
                    else ...[
                      sizeVar(size.height * 0.1),
                      SizedBox(
                        height: 60,
                        width: 60,
                        child: Image.network(
                          'https://cdn-icons-png.flaticon.com/512/1828/1828471.png',
                          color: AppColor.redColor,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Center(
                          child: Text(
                            'It\'s a Private Account, \nConsider being a friend first',
                            style: TextConst.headingStyle(
                              22,
                              AppColor.redColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ),
          );
        } else if (state is GetSingleOtherUserLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return const SizedBox();
      },
    );
  }
}

Widget getInformtion(UserEntity user, BuildContext ctx, String currentUid) {
  final color = Provider.of<ThemeService>(ctx).isDarkMode
      ? AppColor.whiteColor
      : AppColor.blackColor;

  final bg = Provider.of<ThemeService>(ctx).isDarkMode
      ? AppColor.bgDark
      : AppColor.whiteColor;
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(
      children: [
        infoCard(Icons.work, "Work at ", user.work.toString(), color),
        infoCard(Icons.school, "Studied at ", user.college.toString(), color),
        infoCard(Icons.school, "Went to ", user.school.toString(), color),
        infoCard(Icons.home, "Live at ", user.location.toString(), color),
        if (user.uid == currentUid)
          getButton(
              "Milestones",
              () => Navigator.of(ctx).push(MaterialPageRoute(
                  builder: (ctx) => MilestoneScreen(
                        user: user,
                      ))),
              true,
              ctx),
      ],
    ),
  );
}
