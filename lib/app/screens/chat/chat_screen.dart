import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialseed/app/cubits/message/chat_id/chat_cubit.dart';
import 'package:socialseed/app/cubits/message/message_cubit.dart';
import 'package:socialseed/app/screens/chat/message_screen.dart';
import 'package:socialseed/app/widgets/message_tile_widget.dart';
import 'package:socialseed/domain/entities/chat_entity.dart';
import 'package:socialseed/domain/entities/user_entity.dart';
import 'package:socialseed/utils/constants/firebase_const.dart';
import 'package:socialseed/utils/constants/text_const.dart';
import 'package:socialseed/utils/custom/custom_snackbar.dart';
import 'package:uuid/uuid.dart';
import 'package:shimmer/shimmer.dart';

import '../../../data/models/user_model.dart';
import '../../../utils/constants/color_const.dart';
import 'package:socialseed/dependency_injection.dart' as di;

import '../../../utils/custom/shimmer_effect.dart';

class ChatScreen extends StatefulWidget {
  final UserEntity user;

  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<UserEntity> friendList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Fetch both simultaneously
    _initializeData();
  }

  Future<void> _initializeData() async {
    // Start both operations concurrently
    await Future.wait([
      fetchFriends(widget.user.uid!),
      context.read<ChatCubit>().fetchConversation(widget.user.uid!),
    ]);
  }

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
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching friends: $e');
      }
      setState(() {
        _isLoading = false;
      });
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

  Future<List<String>> getUserMessageIds(String currentUid) async {
    final userCollection =
        FirebaseFirestore.instance.collection(FirebaseConst.users);

    try {
      final userDoc = await userCollection.doc(currentUid).get();
      if (userDoc.exists) {
        return List<String>.from(userDoc.data()?['messages'] ?? []);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user message IDs: $e');
      }
    }
    return []; // Return an empty list if there's an error or no IDs found
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display Friends section only if user has friends
            if (friendList.isNotEmpty || _isLoading) ...[
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'Friends',
                  style: TextConst.headingStyle(
                    22,
                    AppColor.blackColor,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: _isLoading
                    ? ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 5,
                        itemBuilder: (ctx, idx) {
                          return shimmerEffectFriends();
                        },
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: friendList.length,
                        itemBuilder: (ctx, idx) {
                          final friend = friendList[idx];

                          return GestureDetector(
                            onTap: () async {
                              final existingMessageId =
                                  await getExistingMessageId(
                                widget.user.uid!,
                                friend.uid!,
                              );

                              if (existingMessageId == null) {
                                // Create a new chat
                                final newMessageId = const Uuid().v4();
                                // ignore: use_build_context_synchronously
                                context.read<ChatCubit>().createMessageId(
                                      chat: ChatEntity(
                                        messageId: newMessageId,
                                        members: [
                                          friend.uid!,
                                          widget.user.uid!
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
                                        sender: widget.user,
                                        receiver: friend,
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
                                        sender: widget.user,
                                        receiver: friend,
                                        messageId: existingMessageId,
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: (friend.activeStatus ?? false)
                                      ? AppColor.redColor
                                      : AppColor.greyShadowColor,
                                  width: 5,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 35,
                                backgroundImage: NetworkImage(friend.imageUrl!),
                                child: ClipOval(
                                  child: Image.network(
                                    friend.imageUrl!,
                                    fit: BoxFit.cover,
                                    width: 70,
                                    height: 70,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                'Conversation',
                style: TextConst.headingStyle(
                  22,
                  AppColor.blackColor,
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: BlocBuilder<ChatCubit, ChatState>(
                builder: (context, state) {
                  // Show shimmer loading initially or when explicitly loading
                  if (state is ChatInitial || state is ChatLoading) {
                    return ListView.builder(
                      itemCount: 5,
                      itemBuilder: (ctx, idx) {
                        return shimmerEffectChat();
                      },
                    );
                  }

                  if (state is ChatLoaded) {
                    final conversations = state.conversations;

                    if (conversations.isEmpty) {
                      return Center(
                        child: Text(
                          'No conversations yet',
                          style: TextConst.RegularStyle(16, AppColor.greyColor),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: conversations.length,
                      itemBuilder: (ctx, idx) {
                        final members = conversations[idx]
                            .members!
                            .where((uid) => uid != widget.user.uid)
                            .toList();

                        // Try to find friend in friendList
                        final friendOptional = friendList
                            .where((friend) => friend.uid == members[0])
                            .toList();

                        // Skip if friend not found
                        if (friendOptional.isEmpty) {
                          return shimmerEffectChat();
                        }

                        final friend = friendOptional.first;

                        return GestureDetector(
                          onTap: () async {
                            final existingMessageId =
                                await getExistingMessageId(
                              widget.user.uid!,
                              friend.uid!,
                            );
                            final messageId =
                                existingMessageId ?? const Uuid().v4();

                            // ignore: use_build_context_synchronously
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (ctx) => BlocProvider<MessageCubit>(
                                  create: (context) => di.sl<MessageCubit>(),
                                  child: MessageScreen(
                                    sender: widget.user,
                                    receiver: friend,
                                    messageId: messageId,
                                  ),
                                ),
                              ),
                            );
                          },
                          child: messageTileWidget(friend, widget.user,
                              conversations[idx].lastMessage!),
                        );
                      },
                    );
                  }

                  if (state is ChatIDCreationError) {
                    failureBar(context, "Message Not Found");
                  }

                  // Keep showing shimmer instead of empty screen for other states
                  return ListView.builder(
                    itemCount: 5,
                    itemBuilder: (ctx, idx) {
                      return shimmerEffectChat();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

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
}
