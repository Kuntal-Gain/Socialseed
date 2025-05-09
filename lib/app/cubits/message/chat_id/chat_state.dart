part of 'chat_cubit.dart';

sealed class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object> get props => [];
}

final class ChatInitial extends ChatState {}

final class ChatLoading extends ChatState {}

// State when a new chat ID is being created
final class ChatCreatingID extends ChatState {}

// State when a chat ID is successfully created
final class ChatIDCreated extends ChatState {
  final String chatId;

  const ChatIDCreated(this.chatId);

  @override
  List<Object> get props => [chatId];
}

// State when a chat ID already exists
final class ChatIDAlreadyExists extends ChatState {
  final String existingChatId;

  const ChatIDAlreadyExists(this.existingChatId);

  @override
  List<Object> get props => [existingChatId];
}

final class ChatIDDoesNotExist extends ChatState {
  final String chatId;

  const ChatIDDoesNotExist(this.chatId);

  @override
  List<Object> get props => [chatId];
}

// State for handling errors during chat ID creation
final class ChatIDCreationError extends ChatState {
  final String message;

  const ChatIDCreationError(this.message);

  @override
  List<Object> get props => [message];
}

final class ChatLoaded extends ChatState {
  final List<ChatEntity> conversations;

  const ChatLoaded({required this.conversations});

  @override
  List<Object> get props => [conversations];
}
