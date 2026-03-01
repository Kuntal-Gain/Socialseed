import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

enum StoryAssetType {
  image,
  video,
  text,
}

StoryAssetType storyAssetTypeFromString(String type) {
  switch (type) {
    case 'image':
      return StoryAssetType.image;
    case 'video':
      return StoryAssetType.video;
    case 'text':
      return StoryAssetType.text;
    default:
      throw Exception('Unknown StoryAssetType: $type');
  }
}

String storyAssetTypeToString(StoryAssetType type) {
  return type.name;
}

class StoryAsset {
  final String id;
  final StoryAssetType type;
  final String? url;
  final String bg;
  final String caption;
  final Timestamp createdAt;

  StoryAsset({
    required this.id,
    required this.type,
    required this.url,
    this.bg = '#FFFFFF',
    required this.caption,
    required this.createdAt,
  });

  factory StoryAsset.fromMap(Map<String, dynamic> map) {
    return StoryAsset(
      id: map['id'],
      type: storyAssetTypeFromString(map['type']),
      url: map['url'],
      bg: map['bg'] ?? '#FFFFFF',
      caption: map['caption'] ?? '',
      createdAt: map['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': storyAssetTypeToString(type),
      'url': url,
      'bg': bg,
      'caption': caption,
      'createdAt': createdAt,
    };
  }
}

class StoryModel {
  final String? storyId;
  final String? creatorUid;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;
  final Timestamp? date;
  final List<StoryAsset>? assets;
  final List<String>? viewers;

  StoryModel({
    this.storyId,
    this.creatorUid,
    this.createdAt,
    this.updatedAt,
    this.date,
    this.assets,
    this.viewers,
  });

  factory StoryModel.fromMap(Map<String, dynamic> map, String docId) {
    return StoryModel(
      storyId: docId,
      creatorUid: map['creatorUid'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
      date: map['date'],
      assets: (map['assets'] as List<dynamic>)
          .map((e) => StoryAsset.fromMap(e))
          .toList(),
      viewers: List<String>.from(map['viewers'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'storyId': storyId,
      'creatorUid': creatorUid,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'date': date,
      'assets': assets?.map((e) => e.toMap()).toList(),
      'viewers': viewers,
    };
  }

  StoryModel copyWith({
    String? storyId,
    String? creatorUid,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    Timestamp? date,
    List<StoryAsset>? assets,
    List<String>? viewers,
  }) {
    return StoryModel(
      storyId: storyId ?? this.storyId,
      creatorUid: creatorUid ?? this.creatorUid,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      date: date ?? this.date,
      assets: assets ?? this.assets,
      viewers: viewers ?? this.viewers,
    );
  }
}
