import 'dart:io';

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

  Future<void> getMessage({required String messageId}) async {
    emit(MessageLoading());
    try {
      final streamResponse = fetchMessageUsecase.call(messageId);
      streamResponse.listen((message) {
        emit(MessageLoaded(messages: message));
      });
    } catch (e) {
      emit(MessageFailure(err: e.toString()));
    }
  }

  Future<void> sendMessage(
      {required String messageId, required String msg}) async {
    try {
      await sendMessageUsecase.call(messageId, msg);
      // getMessage(messageId: messageId);
    } on SocketException catch (_) {
      emit(MessageFailure(err: _.toString()));
    } catch (_) {
      emit(MessageFailure(err: _.toString()));
    }
  }
}
