import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialseed/domain/entities/chat_entity.dart';

class ChatModel extends ChatEntity {
  const ChatModel({
    required String? messageId,
    required List<String>? members,
    required String? lastMessage,
    required bool? isRead,
  }) : super(
          messageId: messageId,
          members: members,
          lastMessage: lastMessage,
          isRead: isRead,
        );

  factory ChatModel.fromJson(DocumentSnapshot snap) {
    var ss = snap.data() as Map<String, dynamic>;

    return ChatModel(
      messageId: ss['messageId'],
      members: List.from(snap.get("members")),
      lastMessage: ss['lastMessage'],
      isRead: ss['isRead'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'members': members,
      'lastMessage': lastMessage,
      'isRead': isRead,
    };
  }
}
