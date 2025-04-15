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

  Stream<List<MessageEntity>> streamMessages(String messageId) {
    final db = FirebaseDatabase.instance.ref();
    final messageRef = db.child("messages").child(messageId).child("chats");

    return messageRef.onValue.map((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) return [];

      return data.entries.map((entry) {
        final msgMap = Map<String, dynamic>.from(entry.value);
        return MessageModel.fromSnapshot(msgMap as DocumentSnapshot<Object?>);
      }).toList()
        ..sort((a, b) => a.createAt!.compareTo(b.createAt!)); // Sort by time
    });
  }
}
