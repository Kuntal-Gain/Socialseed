import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialseed/features/auth_module/model/user_model.dart';

enum PostType { text, image, video }

class PostModel {
  final String? postId;
  final CreatorModel? creator;
  final String? creatorUid;
  final bool? isDeleted;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;
  final PostType? type;
  final String? content;
  final List<String>? assets;
  final List<String>? likes;
  final List<Comment>? comments;

  const PostModel({
    this.postId,
    this.creator,
    this.creatorUid,
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
      'creator': creator?.toJson(),
      'creatorUid': creatorUid,
      'type': type?.name,
      'content': content,
      'assets': assets,
    };
  }

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      postId: json['postId'],
      creator: CreatorModel.fromJson(json['creator']),
      creatorUid: json['creatorUid'],
      isDeleted: json['isDeleted'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      type: PostType.values.firstWhere((e) => e.name == json['type']),
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
  final int? createdAt;
  final int? updatedAt;
  final List<SubComment> subComments;

  const Comment({
    this.commentId,
    this.creator,
    this.content,
    this.createdAt,
    this.updatedAt,
    this.subComments = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'commentId': commentId,
      'creator': creator?.toJson(),
      'content': content,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'subComments': {
        for (final c in subComments) c.commentId!: c.toJson(),
      },
    };
  }

  factory Comment.fromJson(Map<dynamic, dynamic> json) {
    final map = Map<String, dynamic>.from(json.map(
      (key, value) => MapEntry(key.toString(), value),
    ));

    return Comment(
      commentId: map['commentId'],
      creator: map['creator'] != null
          ? CreatorModel.fromJson(
              Map<String, dynamic>.from(
                (map['creator'] as Map).map(
                  (k, v) => MapEntry(k.toString(), v),
                ),
              ),
            )
          : null,
      content: map['content'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
      subComments: map['subComments'] != null
          ? (map['subComments'] as Map)
              .values
              .map((e) => SubComment.fromJson(
                    Map<String, dynamic>.from(
                      (e as Map).map((k, v) => MapEntry(k.toString(), v)),
                    ),
                  ))
              .toList()
          : [],
    );
  }
}

class SubComment {
  final String? commentId;
  final CreatorModel? creator;
  final String? content;
  final int? createdAt;
  final int? updatedAt;

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

  factory SubComment.fromJson(Map<dynamic, dynamic> json) {
    final map = Map<String, dynamic>.from(json.map(
      (key, value) => MapEntry(key.toString(), value),
    ));

    return SubComment(
      commentId: map['commentId'],
      creator: map['creator'] != null
          ? CreatorModel.fromJson(
              Map<String, dynamic>.from(
                (map['creator'] as Map).map(
                  (k, v) => MapEntry(k.toString(), v),
                ),
              ),
            )
          : null,
      content: map['content'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }
}
