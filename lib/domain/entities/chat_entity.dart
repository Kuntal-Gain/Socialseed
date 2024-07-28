import 'package:equatable/equatable.dart';

class ChatEntity extends Equatable {
  final String? messageId; // unique messageid
  final List<String>? members; // 2 members
  final String? lastMessage;
  final bool? isRead;

  const ChatEntity({
    required this.messageId,
    required this.members,
    required this.lastMessage,
    required this.isRead,
  });

  @override
  List<Object?> get props => [messageId, members, lastMessage, isRead];
}
