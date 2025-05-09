import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  @override
  final String? message;
  @override
  final String? senderId;

  final String? messageId;
  final int? timestamp;
  final bool? isSeen;

  const MessageModel({
    required this.message,
    required this.senderId,
    required this.messageId,
    required this.timestamp,
    required this.isSeen,
  }) : super(
          messageId: messageId,
          timestamp: timestamp,
          isSeen: isSeen,
          senderId: senderId,
          message: message,
        );

  factory MessageModel.fromRTDBSnapshot(DataSnapshot snap) {
    final data = snap.value as Map<dynamic, dynamic>;

    return MessageModel(
      messageId: snap.key, // since RTDB doesn’t store the key inside value
      message: data['message'],
      senderId: data['senderId'],
      timestamp: data['timestamp'],
      isSeen: data['isSeen'],
    );
  }

  Map<String, dynamic> toJson() => {
        'senderId': senderId,
        'message': message,
        'messageId': messageId,
        'timestamp': timestamp,
        'isSeen': isSeen,
      };
}
