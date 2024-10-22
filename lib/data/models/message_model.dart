import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  @override
  final String? message;
  @override
  final String? senderId;
  @override
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
      createAt: ss['createAt'], // Ensure this is fetched correctly
    );
  }

  Map<String, dynamic> toJson() => {
        'createAt': createAt,
        'senderId': senderId,
        'message': message,
      };
}
