import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class CommentEntity extends Equatable {
  final String? commentId;
  final String? postId;
  final String? creatorUid;
  final String? content;
  final String? username;
  final String? profileUrl;
  final Timestamp? createAt;
  final List<String>? likes;

  const CommentEntity({
    this.commentId,
    this.postId,
    this.creatorUid,
    this.content,
    this.username,
    this.profileUrl,
    this.createAt,
    this.likes,
  });

  @override
  List<Object?> get props => [
        commentId,
        postId,
        creatorUid,
        content,
        username,
        profileUrl,
        createAt,
        likes,
      ];
}
