import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:socialseed/domain/usecases/chat/create_messageid_usecase.dart';
import 'package:socialseed/domain/usecases/chat/fetch_conversations_usecase.dart';
import 'package:socialseed/domain/usecases/chat/is_messageid_exists_usecase.dart';
// Import your UserModel
// Import Firestore
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

  Future<void> createNewConversation({required ChatEntity chat}) async {
    emit(ChatLoading());

    try {
      await createMessageWithId.call(chat);

      emit(ChatIDCreated(chat.messageId!));
    } catch (e) {
      emit(ChatIDCreationError(e.toString()));
    }
  }

  Future<void> fetchConversations() async {
    emit(ChatLoading());

    try {
      final response = fetchConversationUsecase.call();
      response.listen((conversations) {
        if (conversations.isEmpty) {
          emit(const ChatLoaded(conversations: []));
        } else {
          emit(ChatLoaded(conversations: conversations));
        }
      }, onError: (e) {
        emit(ChatIDCreationError(e.toString()));
      });
    } catch (e) {
      emit(ChatIDCreationError(e.toString()));
    }
  }

  Future<void> isMessageIdExists({required String messageId}) async {
    emit(ChatLoading());

    try {
      final response = await isMessageIdExistsUsecase.call(messageId);

      if (response) {
        emit(ChatIDAlreadyExists(messageId)); // it will load the conversation
      } else {
        emit(ChatIDDoesNotExist(messageId)); // it will create the conversation
      }
    } catch (e) {
      emit(ChatIDCreationError(e.toString()));
    }
  }
}
