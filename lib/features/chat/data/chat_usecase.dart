import 'package:socialseed/features/chat/model/chat_model.dart';

abstract class ChatUsecase {
  /// [CHATLIST] methods
  Future<void> createConversation(String otherUid);
  Stream<List<ChatModel>> getConversationList(String uid);
  Future<void> clearChat(String convoId);

  /// [Message] methods
  Future<void> sendMessage(String convoId, MessageModel message);
  Stream<List<MessageModel>> getMessageStream(String convoId);
  Future<void> markMessageAsRead(String convoId, String messageId);
  Future<void> deleteMessage(String convoId, String messageId);
}
