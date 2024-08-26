import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class StoryEntity extends Equatable {
  final String id;
  final String userId;
  final String storyData;
  final String content;
  final Timestamp createdAt;
  final Timestamp expiresAt;
  final List viewers;

  const StoryEntity({
    required this.id,
    required this.userId,
    required this.storyData,
    required this.createdAt,
    required this.expiresAt,
    required this.viewers,
    required this.content,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        storyData,
        createdAt,
        expiresAt,
        viewers,
      ];
}
