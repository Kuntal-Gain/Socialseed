import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialseed/app/cubits/message/message_cubit.dart';
import 'package:socialseed/app/widgets/message_card_widget.dart';
import 'package:socialseed/domain/entities/user_entity.dart';
import 'package:socialseed/utils/constants/color_const.dart';
import 'package:socialseed/utils/constants/page_const.dart';
import 'package:socialseed/utils/constants/text_const.dart';
import 'package:socialseed/utils/constants/tags_const.dart';

class MessageScreen extends StatefulWidget {
  final UserEntity sender;
  final UserEntity receiver;
  final String messageId;

  const MessageScreen({
    Key? key,
    required this.sender,
    required this.receiver,
    required this.messageId,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<MessageCubit>().getMessage(messageId: widget.messageId);
  }

  void _sendMessage() async {
    if (_controller.text.isEmpty) return;

    BlocProvider.of<MessageCubit>(context)
        .sendMessage(
          messageId: widget.messageId,
          msg: _controller.text,
        )
        .then((value) => _controller.clear());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
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
                    Row(
                      children: [
                        Text(
                          widget.receiver.fullname!,
                          style:
                              TextConst.headingStyle(16, AppColor.blackColor),
                        ),
                        if (widget.receiver.work!.toLowerCase() != "none" &&
                            widget.sender.work!.toLowerCase() ==
                                widget.receiver.work!.toLowerCase())
                          mutualTag("work"),
                        if (widget.receiver.school!.toLowerCase() != "none" &&
                            widget.sender.school!.toLowerCase() ==
                                widget.receiver.school!.toLowerCase())
                          mutualTag("school"),
                        if (widget.receiver.college!.toLowerCase() != "none" &&
                            widget.sender.college!.toLowerCase() ==
                                widget.receiver.college!.toLowerCase())
                          mutualTag("college"),
                        if (widget.receiver.location!.toLowerCase() != "none" &&
                            widget.sender.location!.toLowerCase() ==
                                widget.receiver.location!.toLowerCase())
                          mutualTag("home"),
                      ],
                    ),
                    Text(widget.receiver.activeStatus ?? false
                        ? 'Online'
                        : 'Offline'),
                  ],
                ),
              ],
            ),
            sizeVar(10),
            Expanded(child: BlocBuilder<MessageCubit, MessageState>(
              builder: (context, state) {
                // Debug print to check state changes

                if (state is MessageLoading) {
                  return const Center(
                      child: CircularProgressIndicator(
                    color: AppColor.redColor,
                  ));
                } else if (state is MessageLoaded) {
                  final messages = state.messages;
                  return ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (ctx, idx) {
                      final uid = FirebaseAuth.instance.currentUser!.uid;
                      final message = messages[idx];
                      return messageBox(message.senderId != uid,
                          message.message!, message.createAt!);
                    },
                  );
                } else if (state is MessageFailure) {
                  return Center(child: Text('Error: ${state.err}'));
                } else {
                  return const Center(child: Text('No messages found'));
                }
              },
            )),
            Row(
              children: [
                Expanded(
                  flex: 6,
                  child: Container(
                    height: 60,
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColor.whiteColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColor.greyShadowColor),
                    ),
                    child: TextField(
                      controller: _controller,
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
                      icon: const Icon(
                        Icons.send,
                        color: AppColor.whiteColor,
                      ),
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
