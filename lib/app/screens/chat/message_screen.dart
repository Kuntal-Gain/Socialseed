import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:socialseed/app/cubits/message/message_cubit.dart';
import 'package:socialseed/app/widgets/message_card_widget.dart';
import 'package:socialseed/data/models/message_model.dart';
import 'package:socialseed/domain/entities/user_entity.dart';
import 'package:socialseed/features/services/theme_service.dart';
import 'package:socialseed/utils/constants/color_const.dart';
import 'package:socialseed/utils/constants/text_const.dart';

import '../../../domain/entities/message_entity.dart';

class MessageScreen extends StatefulWidget {
  final UserEntity sender;
  final UserEntity receiver;
  final String chatId;

  const MessageScreen({
    Key? key,
    required this.sender,
    required this.receiver,
    required this.chatId,
  }) : super(key: key);

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _controller = TextEditingController();
  final DatabaseReference _messagesRef = FirebaseDatabase.instance.ref('chats');

  late StreamSubscription<DatabaseEvent> _messageSub;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _listenToMessages();
  }

  void _listenToMessages() {
    _messageSub = _messagesRef
        .child(widget.chatId)
        .child('messages')
        .onChildAdded
        .listen((event) {
      if (!mounted) return;
      context.read<MessageCubit>().fetchMessages(messageId: widget.chatId);
    });
  }

  void _sendMessage() async {
    if (_controller.text.isEmpty) return;

    final messageText = _controller.text;
    final senderId = widget.sender.uid!;
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final newMessage = MessageEntity(
      messageId: widget.chatId,
      senderId: senderId,
      message: messageText,
      timestamp: timestamp,
      isSeen: false,
    );

    await context.read<MessageCubit>().sendMessage(message: newMessage);

    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    _messageSub.cancel(); // 👈 Clean up the subscription
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final textColor =
        themeService.isDarkMode ? AppColor.whiteColor : AppColor.blackColor;
    final backgroundColor =
        themeService.isDarkMode ? AppColor.bgDark : AppColor.whiteColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 🧑‍💻 Header (Receiver Info)
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios),
                ),
                CircleAvatar(
                  radius: 22,
                  backgroundImage: NetworkImage(widget.receiver.imageUrl!),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.receiver.fullname!,
                      style: TextConst.headingStyle(16, textColor),
                    ),
                    Text(
                      (widget.receiver.activeStatus!) ? "Online" : "Offline",
                      style: TextConst.MediumStyle(
                          14,
                          widget.receiver.activeStatus!
                              ? AppColor.redColor
                              : AppColor.greyColor),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),

            // 📨 Messages
            Expanded(
              child: BlocBuilder<MessageCubit, MessageState>(
                builder: (context, state) {
                  if (state is MessageLoading) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: AppColor.redColor));
                  } else if (state is MessageLoaded) {
                    final messages = state.messages;

// Wait till next frame and scroll to bottom
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_scrollController.hasClients) {
                        _scrollController
                            .jumpTo(_scrollController.position.maxScrollExtent);
                      }
                    });

                    final messageItems = getMessageItems(messages);

                    return ListView.builder(
                      itemCount: messageItems.length,
                      controller: _scrollController,
                      itemBuilder: (ctx, idx) {
                        final uid = FirebaseAuth.instance.currentUser!.uid;
                        final item = messageItems[idx];

                        if (item['type'] == 'date') {
                          final date = item['value'] as int;

                          String label;
                          final now = DateTime.now();
                          if (isSameDay(
                              DateTime.fromMillisecondsSinceEpoch(date), now)) {
                            label = 'Today';
                          } else if (isSameDay(
                              DateTime.fromMillisecondsSinceEpoch(date),
                              now.subtract(Duration(days: 1)))) {
                            label = 'Yesterday';
                          } else {
                            label = DateFormat('MMM d, yyyy').format(
                                DateTime.fromMillisecondsSinceEpoch(date));
                          }

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Spacer(),
                              Text(
                                label,
                                style: TextConst.headingStyle(22, textColor),
                              ),
                              const Spacer(),
                            ],
                          );
                        } else {
                          final message = item['value'] as MessageModel;
                          final uid = FirebaseAuth.instance.currentUser!.uid;

                          if (message.message!.isEmpty) return const SizedBox();
                          return messageBox(
                            message.senderId != uid,
                            message.message!,
                            message.timestamp!,
                            context,
                          );
                        }
                      },
                    );
                  } else if (state is MessageFailure) {
                    return Center(child: Text('Error: ${state.err}'));
                  } else {
                    return const Center(child: Text('No messages found'));
                  }
                },
              ),
            ),

            // ✍️ Input + Send Button
            Row(
              children: [
                Expanded(
                  flex: 6,
                  child: Container(
                    height: 60,
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: themeService.isDarkMode
                              ? AppColor.blackColor
                              : AppColor.greyShadowColor,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _controller,
                      style: TextConst.headingStyle(16, textColor),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        hintText: 'Type a message',
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: CircleAvatar(
                    radius: 38,
                    backgroundColor: AppColor.redColor,
                    child: IconButton(
                      onPressed: _sendMessage,
                      icon: const Icon(Icons.send, color: AppColor.whiteColor),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
