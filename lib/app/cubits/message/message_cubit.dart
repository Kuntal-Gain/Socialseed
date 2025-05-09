import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:socialseed/domain/usecases/chat/fetch_message_usecase.dart';
import 'package:socialseed/domain/usecases/chat/send_message_usecase.dart';

import '../../../data/models/message_model.dart';
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
    emit(MessageLoading());

    try {
      if (message.messageId == null || message.message == null) {
        emit(MessageFailure(err: "Missing message ID or message text"));
        return;
      }

      await sendMessageUsecase.call(message.messageId!, message.message!);
      emit(MessageSuccess(message: "Message sent successfully"));
    } catch (e) {
      emit(MessageFailure(err: e.toString()));
    }
  }

  Future<void> fetchMessages({required String messageId}) async {
    emit(MessageLoading());

    try {
      final response = fetchMessageUsecase.call(messageId);
      response.listen((messages) {
        if (messages.isEmpty) {
          emit(MessageLoaded(messages: const []));
        } else {
          emit(MessageLoaded(messages: messages));
        }
      }, onError: (e) {
        emit(MessageFailure(err: e.toString()));
      });
    } catch (e) {
      emit(MessageFailure(err: e.toString()));
    }
  }
}
