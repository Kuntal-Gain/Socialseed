import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialseed/features/post/model/post_model.dart';

abstract class PostUsecase {
  /// [POST] module
  Future<void> createPost(PostModel post);
  Future<void> toggleLikePost(String postId);
  Future<List<PostModel>> getAllPosts({
    int limit = 10,
    DocumentSnapshot? lastDoc,
  });
  Future<List<PostModel>> getUserPosts(String uid);
  Future<PostModel> getPost(String postId);
  Stream<List<String>> likeCountStream(String postId);
  Future<void> updatePost(PostModel post, String postId);
  Future<void> deletePost(String postId);

  /// [COMMENT] module
  Future<void> createComment(String postId, Comment comment);
  Future<void> replyComment(String postId, String commentId, SubComment reply);
  Stream<List<Comment>> getComments(String postId);
  Future<void> deleteComment(String postId, String commentId);
}
