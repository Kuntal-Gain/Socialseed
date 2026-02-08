import 'package:firebase_database/firebase_database.dart';

class RequestListModel {
  final List<RequestModel> requests;
  final int count;

  const RequestListModel({
    required this.requests,
    required this.count,
  });

  factory RequestListModel.fromJson(Map<String, dynamic> json) {
    final list = (json['requests'] as List<dynamic>? ?? [])
        .map((e) => RequestModel.fromJson(
              Map<String, dynamic>.from(e as Map),
            ))
        .toList();

    return RequestListModel(
      requests: list,
      count: json['count'] ?? list.length,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requests': requests.map((e) => e.toJson()).toList(),
      'count': count,
    };
  }
}

class RequestModel {
  final String uid;
  final String fullName;
  final String? avatarUrl;

  final int? createdAt;

  const RequestModel({
    required this.uid,
    required this.fullName,
    this.avatarUrl,
    this.createdAt,
  });

  factory RequestModel.fromJson(Map json) {
    final data = Map<String, dynamic>.from(json);

    return RequestModel(
      uid: data['uid'] as String,
      fullName: data['fullName'] as String,
      avatarUrl: data['avatarUrl'] as String?,
      createdAt: (data['createdAt'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'fullName': fullName,
      'avatarUrl': avatarUrl,
      'createdAt': ServerValue.timestamp,
    };
  }

  RequestModel copyWith({
    String? uid,
    String? fullName,
    String? avatarUrl,
    int? createdAt,
  }) {
    return RequestModel(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
