import 'package:equatable/equatable.dart';

class MessageEntity extends Equatable {
  final String? messageId;
  final String? senderId;
  final String? message;
  final int? timestamp;
  final bool? isSeen;

  const MessageEntity({
    required this.messageId,
    required this.senderId,
    required this.message,
    required this.timestamp,
    required this.isSeen,
  });

  factory MessageEntity.fromMap(Map<String, dynamic> map, String messageId) {
    return MessageEntity(
      messageId: messageId,
      senderId: map['senderId'],
      message: map['message'],
      timestamp: map['timestamp'],
      isSeen: map['isSeen'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'message': message,
      'timestamp': timestamp,
      'isSeen': isSeen,
    };
  }

  @override
  List<Object?> get props => [
        messageId,
        senderId,
        message,
        timestamp,
        isSeen,
      ];
}
