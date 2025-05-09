part of 'message_cubit.dart';

sealed class MessageState extends Equatable {
  const MessageState();
}

final class MessageInitial extends MessageState {
  @override
  List<Object> get props => [];
}

final class MessageLoading extends MessageState {
  @override
  List<Object> get props => [];
}

// ignore: must_be_immutable
final class MessageLoaded extends MessageState {
  List<MessageEntity> messages;

  MessageLoaded({required this.messages});

  @override
  List<Object> get props => [messages];
}

final class MessageFailure extends MessageState {
  final String err;

  const MessageFailure({required this.err});

  @override
  List<Object> get props => [err];
}

final class MessageSuccess extends MessageState {
  final String message;

  const MessageSuccess({required this.message});

  @override
  List<Object> get props => [message];
}
