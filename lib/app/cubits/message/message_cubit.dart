import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:socialseed/domain/usecases/chat/fetch_message_usecase.dart';
import 'package:socialseed/domain/usecases/chat/send_message_usecase.dart';

import '../../../domain/entities/message_entity.dart';

part 'message_state.dart';

class MessageCubit extends Cubit<MessageState> {
  final SendMessageUsecase sendMessageUsecase;
  final FetchMessageUsecase fetchMessageUsecase;

  MessageCubit({
    required this.sendMessageUsecase,
    required this.fetchMessageUsecase,
  }) : super(MessageInitial());

  Future<void> sendMessage({required MessageEntity message}) async {
    try {
      // Optimistic UI update (add to current state)
      if (state is MessageLoaded) {
        final currentMessages =
            List<MessageEntity>.from((state as MessageLoaded).messages);
        emit(MessageLoaded(messages: [...currentMessages, message]));
      }

      await sendMessageUsecase.call(message.messageId!, message.message!);

      // Wait for listener to refresh real data, OR re-fetch manually
      // Optionally skip re-fetching to avoid flicker if optimistic data is good enough
      // fetchMessages(messageId: message.messageId!);
    } catch (e) {
      emit(MessageFailure(err: e.toString()));
    }
  }

  void fetchMessages({required String messageId}) async {
    if (isClosed) return; // 🛑 Prevents emit after close
    try {
      emit(MessageLoading());
      final messages = fetchMessageUsecase.call(messageId);
      messages.listen((messages) {
        if (!isClosed) emit(MessageLoaded(messages: messages));
      }, onError: (e) {
        if (!isClosed) emit(MessageFailure(err: e.toString()));
      });
    } catch (e) {
      if (!isClosed) emit(MessageFailure(err: e.toString()));
    }
  }
}
