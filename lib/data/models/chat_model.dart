import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialseed/domain/entities/chat_entity.dart';

class ChatModel extends ChatEntity {
  const ChatModel({
    required String? messageId,
    required List<String>? members,
    required String? lastMessage,
    required List<String>? isRead,
    required String? lastMessageSenderId,
    required int? timestamp,
  }) : super(
          messageId: messageId,
          members: members,
          lastMessage: lastMessage,
          isRead: isRead,
          lastMessageSenderId: lastMessageSenderId,
          timestamp: timestamp,
        );

  factory ChatModel.fromJson(DocumentSnapshot snap) {
    var ss = snap.data() as Map<String, dynamic>;

    return ChatModel(
      messageId: ss['messageId'],
      members: List.from(snap.get("members")),
      lastMessage: ss['lastMessage'],
      isRead: List.from(ss['isRead'] as List<dynamic>),
      lastMessageSenderId: ss['lastMessageSenderId'],
      timestamp: ss['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'members': members,
      'lastMessage': lastMessage,
      'isRead': isRead,
      'lastMessageSenderId': lastMessageSenderId,
      'timestamp': timestamp,
    };
  }
}
