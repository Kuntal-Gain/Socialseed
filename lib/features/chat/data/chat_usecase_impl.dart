import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:socialseed/core/usecases/usecases_impl.dart';
import 'package:socialseed/features/chat/data/chat_usecase.dart';
import 'package:socialseed/features/chat/model/chat_model.dart';

import '../../../core/utils/helpers/converter.dart';

class ChatUsecaseImpl implements ChatUsecase {
  final DatabaseReference db = FirebaseDatabase.instance.ref();

  /// [CHATLIST] methods
  @override
  Future<void> createConversation(String otherUid) async {
    try {
      final convRef = db.child("conversations").push();
      final convId = convRef.key!;
      final myUid = await getCurrentUid();

      final now = DateTime.now().millisecondsSinceEpoch;

      final chat = ChatModel(
        id: convId,
        participants: {
          myUid: true,
          otherUid: true,
        },
        type: ChatType.dm,
        createdAt: now,
        lastMessage: LastMessageModel(
          text: "",
          senderId: "",
          type: MessageType.system,
          createdAt: now,
        ),
        unreadCount: {
          myUid: 0,
          otherUid: 0,
        },
      );

      await convRef.set(chat.toMap());

      await db.child("userConversations/$myUid/$convId").set(true);
      await db.child("userConversations/$otherUid/$convId").set(true);
    } on FirebaseException catch (e) {
      throw Exception("Failed to create conversation: ${e.message}");
    } catch (e) {
      throw Exception("Unexpected error creating conversation: $e");
    }
  }

  @override
  Stream<List<ChatModel>> getConversationList(String uid) {
    // final ref = db.child("userConversations/$myUid");

    // return ref.onValue.asyncMap((event) async {
    //   try {
    //     final data = event.snapshot.value;

    //     if (data == null) return [];

    //     final convoIds = Map<String, dynamic>.from(data as Map).keys.toList();

    //     List<ChatModel> chats = [];

    //     for (final id in convoIds) {
    //       final snap = await db.child("conversations/$id").get();
    //       if (snap.exists) {
    //         chats.add(ChatModel.fromMap(
    //             Map<String, dynamic>.from(snap.value as Map)));
    //       }
    //     }

    //     chats.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    //     return chats;
    //   } catch (e) {
    //     throw Exception("Failed to load conversations: $e");
    //   }
    // });
    final userRef = db.child("userConversations/$uid");

    return userRef.onValue.asyncExpand((event) {
      final data = event.snapshot.value;

      if (data == null) {
        return Stream.value([]);
      }

      final ids = Map<String, dynamic>.from(data as Map).keys;

      final controller = StreamController<List<ChatModel>>();

      List<ChatModel> chats = [];

      for (final id in ids) {
        db.child("conversations/$id").onValue.listen((snap) {
          if (!snap.snapshot.exists) return;

          final chat = ChatModel.fromMap(
            Map<String, dynamic>.from(snap.snapshot.value as Map),
          );

          chats.removeWhere((c) => c.id == chat.id);
          chats.add(chat);

          chats.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          controller.add(List.from(chats));
        });
      }

      return controller.stream;
    });
  }

  @override
  Future<void> clearChat(String convoId) async {
    try {
      await db.child("messages/$convoId").remove();
    } on FirebaseException catch (e) {
      throw Exception("Failed to clear chat: ${e.message}");
    } catch (e) {
      throw Exception("Unexpected error clearing chat: $e");
    }
  }

  /// [CHAT] methods
  @override
  Future<void> sendMessage(String convoId, MessageModel message) async {
    try {
      final msgRef = db.child("messages/$convoId").push();
      final msgId = msgRef.key!;

      final msg = message.copyWith(id: msgId);

      // get conversation to know participants
      final convoSnap = await db.child("conversations/$convoId").get();
      final convoData = Map<String, dynamic>.from(convoSnap.value as Map);

      final participants = Map<String, dynamic>.from(convoData["participants"]);

      Map<String, dynamic> updates = {
        "messages/$convoId/$msgId": msg.toMap(),
        "conversations/$convoId/lastMessage": {
          "text": msg.text,
          "senderId": msg.senderId,
          "type": enumToString(msg.type),
          "createdAt": msg.createdAt,
        },
        "conversations/$convoId/createdAt": msg.createdAt,
      };

      for (final uid in participants.keys) {
        if (uid == msg.senderId) {
          updates["conversations/$convoId/unreadCount/$uid"] = 0;
        } else {
          final current = (convoData["unreadCount"]?[uid] ?? 0) as int;

          updates["conversations/$convoId/unreadCount/$uid"] = current + 1;
        }
      }

      await db.update(updates);
    } catch (e) {
      throw Exception("Failed to send message: $e");
    }
  }

  @override
  Stream<List<MessageModel>> getMessageStream(String convoId) {
    final ref = db.child("messages/$convoId");

    return ref.onValue.map((event) {
      try {
        final data = event.snapshot.value;

        if (data == null) return [];

        final map = Map<String, dynamic>.from(data as Map<dynamic, dynamic>);

        final messages = map.entries.map((e) {
          final msg =
              Map<String, dynamic>.from(e.value as Map<dynamic, dynamic>);
          msg["id"] = e.key;
          return MessageModel.fromMap(msg);
        }).toList();

        messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

        return messages;
      } catch (e) {
        throw Exception("Failed to parse messages: $e");
      }
    });
  }

  @override
  Future<void> markMessageAsRead(String convoId, String messageId) async {
    final myUid = await getCurrentUid();

    try {
      await db.child("messages/$convoId/$messageId/readBy/$myUid").set(true);
    } on FirebaseException catch (e) {
      throw Exception("Failed to mark message as read: ${e.message}");
    } catch (e) {
      throw Exception("Unexpected error marking message as read: $e");
    }
  }

  @override
  Future<void> deleteMessage(String convoId, String messageId) async {
    try {
      await db.child("messages/$convoId/$messageId").remove();
    } on FirebaseException catch (e) {
      throw Exception("Failed to delete message: ${e.message}");
    } catch (e) {
      throw Exception("Unexpected error deleting message: $e");
    }
  }
}
