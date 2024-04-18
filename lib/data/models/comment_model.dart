import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/comment_entity.dart';

class CommentModel extends CommentEntity {
  // ignore: overridden_fields
  final String? commentId;
  final String? postId;
  final String? creatorUid;
  final String? content;
  final String? username;
  final String? profileUrl;
  final Timestamp? createAt;
  final List<String>? likes;

  CommentModel({
    this.commentId,
    this.postId,
    this.creatorUid,
    this.content,
    this.username,
    this.profileUrl,
    this.createAt,
    this.likes,
  }) : super(
          postId: postId,
          creatorUid: creatorUid,
          content: content,
          profileUrl: profileUrl,
          username: username,
          likes: likes,
          createAt: createAt,
          commentId: commentId,
        );

  factory CommentModel.fromSnapshot(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return CommentModel(
      postId: snapshot['postId'],
      creatorUid: snapshot['creatorUid'],
      content: snapshot['content'],
      profileUrl: snapshot['profileUrl'],
      commentId: snapshot['commentId'],
      createAt: snapshot['createAt'],
      username: snapshot['username'],
      likes: List.from(snap.get("likes")),
    );
  }

  Map<String, dynamic> toJson() => {
        "creatorUid": creatorUid,
        "content": content,
        "profileUrl": profileUrl,
        "commentId": commentId,
        "createAt": createAt,
        "postId": postId,
        "likes": likes,
        "username": username,
      };
}
