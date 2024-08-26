// ignore_for_file: overridden_fields, annotate_overrides

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialseed/domain/entities/story_entity.dart';

class StoryModel extends StoryEntity {
  final String id;
  final String userId;
  final String storyData;
  final Timestamp createdAt;
  final Timestamp expiresAt;
  final List viewers;
  final String content;

  const StoryModel({
    required this.id,
    required this.userId,
    required this.storyData,
    required this.createdAt,
    required this.expiresAt,
    required this.viewers,
    required this.content,
  }) : super(
          id: id,
          userId: userId,
          storyData: storyData,
          createdAt: createdAt,
          expiresAt: expiresAt,
          viewers: viewers,
          content: content,
        );

  factory StoryModel.fromSnapshot(DocumentSnapshot snap) {
    final ss = snap.data() as Map<String, dynamic>;

    return StoryModel(
      id: ss['id'] ?? '',
      userId: ss['userId'] ?? '',
      storyData: ss['storyData'] ?? '',
      createdAt: ss['createdAt'] ?? Timestamp.now(),
      expiresAt: ss['expiresAt'] ?? Timestamp.now(),
      viewers: ss['viewers'] ?? [],
      content: ss['content'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'storyData': storyData,
      'createdAt': createdAt,
      'expiresAt': expiresAt,
      'viewers': viewers,
      'content': content,
    };
  }
}
