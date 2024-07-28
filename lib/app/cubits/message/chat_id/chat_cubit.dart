import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:socialseed/domain/usecases/chat/create_messageid_usecase.dart';
import 'package:socialseed/domain/usecases/chat/fetch_conversations_usecase.dart';
import 'package:socialseed/domain/usecases/chat/is_messageid_exists_usecase.dart';
import '../../../../domain/entities/chat_entity.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final CreateMessageWithId createMessageWithId;
  final FetchConversationUsecase fetchConversationUsecase;
  final IsMessageIdExistsUsecase isMessageIdExistsUsecase;

  ChatCubit({
    required this.createMessageWithId,
    required this.fetchConversationUsecase,
    required this.isMessageIdExistsUsecase,
  }) : super(ChatInitial());

  Future<void> createMessageId({required ChatEntity chat}) async {
    try {
      if (chat.messageId == null) {
        emit(const ChatIDCreationError('Message ID is null'));
        return;
      }

      final isExists = await isMessageIdExistsUsecase.call(chat.messageId!);
      if (!isExists) {
        await createMessageWithId.call(chat);
        emit(ChatIDCreated(chat.messageId!));
      } else {
        emit(ChatIDAlreadyExists(chat.messageId!));
      }
    } on SocketException catch (e) {
      emit(ChatIDCreationError('No Internet connection: ${e.message}'));
    } catch (e) {
      emit(ChatIDCreationError('An error occurred: ${e.toString()}'));
    }
  }

  Future<void> fetchConversation() async {
    emit(ChatLoading());

    try {
      final streamResponse = fetchConversationUsecase.call();
      streamResponse.listen((chatIds) {
        emit(ChatLoaded(conversations: chatIds));
      });
    } catch (e) {
      emit(ChatIDCreationError('An error occurred: ${e.toString()}'));
    }
  }
}
