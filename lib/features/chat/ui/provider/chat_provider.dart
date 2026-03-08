import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socialseed/core/network/locator.dart';
import 'package:socialseed/features/chat/data/chat_usecase.dart';

import '../../../auth_module/data/auth/auth_usecase.dart';
import '../../model/chat_model.dart';

final selectedConversationProvider = StateProvider<ChatModel?>((ref) => null);

final chatListProvider =
    StreamNotifierProvider.autoDispose<ChatListNotifier, List<ChatModel>>(
        ChatListNotifier.new);

// class ChatListNotifier extends AutoDisposeAsyncNotifier<List<ChatModel>> {
//   final _chatUsecase = getIt<ChatUsecase>();
//   StreamSubscription<List<ChatModel>>? _sub;

//   @override
//   @override
//   Future<List<ChatModel>> build() async {
//     final uid = await getIt<AuthUsecases>().getCurrentUid();

//     final stream = _chatUsecase.getConversationList(uid!);

//     _sub = stream.listen(
//       (chats) {
//         state = AsyncValue.data(chats);
//       },
//       onError: (e, st) {
//         state = AsyncValue.error(e, st);
//       },
//     );

//     ref.onDispose(() {
//       _sub?.cancel();
//     });

//     // wait for first value instead of returning []
//     return stream.first;
//   }

//   Future<void> createConversation(String otherUid) async {
//     await _chatUsecase.createConversation(otherUid);
//   }

//   Future<void> clearChat(String convoId) async {
//     await _chatUsecase.clearChat(convoId);
//   }
// }

class ChatListNotifier extends AutoDisposeStreamNotifier<List<ChatModel>> {
  final _chatUsecase = getIt<ChatUsecase>();

  @override
  Stream<List<ChatModel>> build() async* {
    final uid = await getIt<AuthUsecases>().getCurrentUid();

    yield* _chatUsecase.getConversationList(uid!);
  }

  Future<void> createConversation(String otherUid) async {
    await _chatUsecase.createConversation(otherUid);
  }

  Future<void> clearChat(String convoId) async {
    await _chatUsecase.clearChat(convoId);
  }
}

final messageProvider =
    AutoDisposeAsyncNotifierProvider<MessageNotifier, List<MessageModel>>(
        MessageNotifier.new);

class MessageNotifier extends AutoDisposeAsyncNotifier<List<MessageModel>> {
  final ChatUsecase _chatUsecase = getIt<ChatUsecase>();
  StreamSubscription<List<MessageModel>>? _sub;

  String? _convoId;

  @override
  Future<List<MessageModel>> build() async {
    state = const AsyncValue.loading();

    _convoId = ref.watch(selectedConversationProvider)?.id;

    if (_convoId == null) return [];

    _sub = _chatUsecase.getMessageStream(_convoId!).listen(
      (messages) {
        state = AsyncValue.data(messages);
      },
      onError: (e, st) {
        state = AsyncValue.error(e, st);
      },
    );

    ref.onDispose(() {
      _sub?.cancel();
    });

    return [];
  }

  Future<void> sendMessage(MessageModel message) async {
    if (_convoId == null) return;

    await _chatUsecase.sendMessage(_convoId!, message);
  }

  Future<void> deleteMessage(String messageId) async {
    if (_convoId == null) return;

    await _chatUsecase.deleteMessage(_convoId!, messageId);
  }

  Future<void> markMessageAsRead(String messageId) async {
    if (_convoId == null) return;

    await _chatUsecase.markMessageAsRead(_convoId!, messageId);
  }

  Future<void> clearChat() async {
    if (_convoId == null) return;

    await _chatUsecase.clearChat(_convoId!);
  }
}
