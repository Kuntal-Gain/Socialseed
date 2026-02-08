import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart' hide Query;
import 'package:flutter/foundation.dart';
import 'package:socialseed/core/usecases/usecases_impl.dart';
import 'package:socialseed/features/post/model/post_model.dart';
import 'post_usecase.dart';

class PostUsecaseImpl implements PostUsecase {
  final _firestore = FirebaseFirestore.instance;
  final rtdb = FirebaseDatabase.instance.ref();

  CollectionReference get _postsRef => _firestore.collection('posts');

  // ────────────────────────────────
  // CREATE
  // ────────────────────────────────
  @override
  Future<void> createPost(PostModel post) async {
    try {
      final docRef = _postsRef.doc(); // 🔥 Firestore generates ID

      final payload = {
        ...post.toJson(),
        'postId': docRef.id,
        'isDeleted': false,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
        'likes': <String>[],
        'comments': [],
      };

      await docRef.set(payload);
    } catch (e, st) {
      debugPrint('createPost error: $e\n$st');
      rethrow;
    }
  }

  // ────────────────────────────────
  // UPDATE
  // ────────────────────────────────
  @override
  Future<void> updatePost(PostModel post, String postId) async {
    try {
      await _postsRef.doc(postId).update(post.toJson());
    } catch (e, st) {
      debugPrint('updatePost error: $e\n$st');
      rethrow;
    }
  }

  // ────────────────────────────────
  // GET ALL (PAGINATED)
  // ────────────────────────────────
  @override
  Future<List<PostModel>> getAllPosts({
    int limit = 10,
    DocumentSnapshot? lastDoc,
  }) async {
    try {
      Query query =
          _postsRef.orderBy('createdAt', descending: true).limit(limit);

      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc);
      }

      final snap = await query.get();

      return snap.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return PostModel.fromJson(data);
      }).toList();
    } catch (e, st) {
      debugPrint('getAllPosts error: $e\n$st');
      rethrow;
    }
  }

  // ────────────────────────────────
  // GET USER POSTS
  // ────────────────────────────────
  @override
  Future<List<PostModel>> getUserPosts(String uid) async {
    try {
      final snap = await _postsRef
          .where('creatorUid', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .get();

      return snap.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return PostModel.fromJson(data);
      }).toList();
    } catch (e, st) {
      debugPrint('getUserPosts error: $e\n$st');
      rethrow;
    }
  }

  // ────────────────────────────────
  // GET SINGLE POST
  // ────────────────────────────────
  @override
  Future<PostModel> getPost(String postId) async {
    try {
      final doc = await _postsRef.doc(postId).get();

      if (!doc.exists) {
        throw Exception('Post not found');
      }

      final data = doc.data() as Map<String, dynamic>;
      return PostModel.fromJson(data);
    } catch (e, st) {
      debugPrint('getPost error: $e\n$st');
      rethrow;
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    try {
      await _postsRef.doc(postId).update({'isDeleted': true});
    } catch (e, st) {
      debugPrint('deleted error: $e\n$st');
      rethrow;
    }
  }

  // ────────────────────────────────
  // LIKE SERVICE
  // ────────────────────────────────

  @override
  Stream<List<String>> likeCountStream(String postId) {
    return rtdb.child("posts/$postId/likes").onValue.map((event) {
      if (!event.snapshot.exists) return <String>[];

      final data = Map<String, dynamic>.from(
        event.snapshot.value as Map,
      );

      // Keep only keys where value == true
      return data.entries
          .where((e) => e.value == true)
          .map((e) => e.key)
          .toList();
    });
  }

  @override
  Future<void> toggleLikePost(String postId) async {
    final uid = await getCurrentUid();

    final likeRef = rtdb.child("posts/$postId/likes/$uid");

    final isLiked = await likeRef.get();

    if (isLiked.exists) {
      await likeRef.remove();
    } else {
      await likeRef.set(true);
    }
  }

  @override
  Future<void> createComment(String postId, Comment comment) async {
    final commentRef = rtdb.child("posts/$postId/comments").push();

    await commentRef.set({
      'commentId': commentRef.key,
      'creator': comment.creator?.toJson(),
      'content': comment.content,
      'createdAt': ServerValue.timestamp,
      'updatedAt': ServerValue.timestamp,
      'subComments': {},
    });
  }

  @override
  Future<void> deleteComment(String postId, String commentId) async {
    await rtdb.child("posts/$postId/comments/$commentId").remove();
  }

  @override
  Stream<List<Comment>> getComments(String postId) {
    return rtdb.child("posts/$postId/comments").onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data == null) return [];

      return data.entries.map((e) => Comment.fromJson(e.value as Map)).toList()
        ..sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));
    });
  }

  @override
  Future<void> replyComment(
      String postId, String commentId, SubComment reply) async {
    final replyRef =
        rtdb.child("posts/$postId/comments/$commentId/subComments").push();

    await replyRef.set({
      'commentId': replyRef.key,
      'creator': reply.creator?.toJson(),
      'content': reply.content,
      'createdAt': ServerValue.timestamp,
      'updatedAt': ServerValue.timestamp,
    });
  }
}
