import 'package:equatable/equatable.dart';

class ChatEntity extends Equatable {
  final String? messageId; // Unique chat/convo ID
  final List<String>? members; // Usually 2 users
  final String? lastMessage;
  final String? lastMessageSenderId;
  final int? timestamp; // Epoch time of last message
  final Map<String, bool>? isRead; // Per-user read status

  const ChatEntity({
    required this.messageId,
    required this.members,
    required this.lastMessage,
    required this.lastMessageSenderId,
    required this.timestamp,
    required this.isRead,
  });

  @override
  List<Object?> get props => [
        messageId,
        members,
        lastMessage,
        lastMessageSenderId,
        timestamp,
        isRead,
      ];
}
