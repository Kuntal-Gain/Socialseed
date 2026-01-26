import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialseed/features/auth_module/model/user_model.dart';

enum Type { text, image, video }

class PostModel {
  final String? postId;
  final CreatorModel? creator;
  final bool? isDeleted;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;
  final Type? type;
  final String? content;
  final List<String>? assets;
  final List<String>? likes;
  final List<Comment>? comments;

  const PostModel({
    this.postId,
    this.creator,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
    this.type,
    this.content,
    this.assets,
    this.likes,
    this.comments,
  });

  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'creator': creator?.toJson(),
      'isDeleted': isDeleted,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'type': type?.name,
      'content': content,
      'assets': assets,
      'likes': likes,
      'comments': comments?.map((x) => x.toJson()).toList(),
    };
  }

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      postId: json['postId'],
      creator: CreatorModel.fromJson(json['creator']),
      isDeleted: json['isDeleted'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      type: Type.values.firstWhere((e) => e.name == json['type']),
      content: json['content'],
      assets: List<String>.from(json['assets']),
      likes: List<String>.from(json['likes']),
      comments:
          List<Comment>.from(json['comments']?.map((x) => Comment.fromJson(x))),
    );
  }
}

class CreatorModel {
  final String? uid;
  final String? name;
  final String? username;
  final String? avatarUrl;
  final ProfileHistory? profileHistory; // used for relativity mutual

  CreatorModel({
    this.uid,
    this.name,
    this.username,
    this.avatarUrl,
    this.profileHistory,
  });
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'username': username,
      'avatarUrl': avatarUrl,
      'profileHistory': profileHistory,
    };
  }

  factory CreatorModel.fromJson(Map<String, dynamic> json) {
    return CreatorModel(
      uid: json['uid'],
      name: json['name'],
      username: json['username'],
      avatarUrl: json['avatarUrl'],
      profileHistory: json['profileHistory'],
    );
  }
}

class Comment {
  final String? commentId;
  final CreatorModel? creator;
  final String? content;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;
  final List<SubComment>? subComments;

  const Comment({
    this.commentId,
    this.creator,
    this.content,
    this.createdAt,
    this.updatedAt,
    this.subComments,
  });

  Map<String, dynamic> toJson() {
    return {
      'commentId': commentId,
      'creator': creator?.toJson(),
      'content': content,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'subComments': subComments,
    };
  }

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      commentId: json['commentId'],
      creator: CreatorModel.fromJson(json['creator']),
      content: json['content'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      subComments: json['subComments'],
    );
  }
}

class SubComment {
  final String? commentId;
  final CreatorModel? creator;
  final String? content;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  const SubComment({
    this.commentId,
    this.creator,
    this.content,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'commentId': commentId,
      'creator': creator?.toJson(),
      'content': content,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory SubComment.fromJson(Map<String, dynamic> json) {
    return SubComment(
      commentId: json['commentId'],
      creator: CreatorModel.fromJson(json['creator']),
      content: json['content'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}
