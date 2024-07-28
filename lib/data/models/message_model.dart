// ignore_for_file: overridden_fields, annotate_overrides

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialseed/domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  final String? message;
  final String? senderId;
  final Timestamp? createAt;

  const MessageModel({
    required this.message,
    required this.senderId,
    required this.createAt,
  }) : super(
          createAt: createAt,
          senderId: senderId,
          message: message,
        );

  factory MessageModel.fromSnapshot(DocumentSnapshot snap) {
    var ss = snap.data() as Map<String, dynamic>;

    return MessageModel(
      message: ss['message'],
      senderId: ss['senderId'],
      createAt: ss['createAt'],
    );
  }

  Map<String, dynamic> toJson() => {
        'createAt': createAt,
        'senderId': senderId,
        'message': message,
      };
}
