import '../../../core/utils/helpers/converter.dart';

/// Defines the category of a chat session.
enum ChatType {
  dm, // Direct Message (1-on-1)
  group, // Multi-user group
  broadcast, // One-to-many announcements
}

/// Defines the content type of a specific message.
enum MessageType {
  text,
  image,
  video,
  audio,
  document,
  system, // e.g., "User joined the group"
}

/// Represents a chat thread/room containing metadata and the latest activity.
class ChatModel {
  final String id;

  /// Map of userId to a boolean (e.g., active status or participation)
  final Map<String, bool> participants;
  final ChatType type;
  final int createdAt;

  final LastMessageModel lastMessage;

  /// Tracks how many messages are unread for each specific userId
  final Map<String, int> unreadCount;

  ChatModel({
    required this.id,
    required this.participants,
    required this.type,
    required this.createdAt,
    required this.lastMessage,
    required this.unreadCount,
  });

  factory ChatModel.fromMap(Map<String, dynamic> data) {
    return ChatModel(
      id: data["id"] ?? "",
      participants: Map<String, bool>.from(data["participants"] ?? {}),
      type: enumFromString(
        ChatType.values,
        data["type"],
        ChatType.dm,
      ),
      createdAt: data["createdAt"] ?? 0,
      lastMessage: LastMessageModel.fromMap(
        Map<String, dynamic>.from(data["lastMessage"] ?? {}),
      ),
      unreadCount: Map<String, int>.from(data["unreadCount"] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "participants": participants,
      "type": enumToString(type),
      "createdAt": createdAt,
      "lastMessage": lastMessage.toMap(),
      "unreadCount": unreadCount,
    };
  }
}

/// A lightweight preview of the last message sent in a chat.
class LastMessageModel {
  final String text;
  final String senderId;
  final MessageType type;
  final int createdAt;

  LastMessageModel({
    required this.text,
    required this.senderId,
    required this.type,
    required this.createdAt,
  });

  factory LastMessageModel.fromMap(Map<String, dynamic> data) {
    return LastMessageModel(
      text: data["text"] ?? "",
      senderId: data["senderId"] ?? "",
      type: enumFromString(
        MessageType.values,
        data["type"],
        MessageType.text,
      ),
      createdAt: data["createdAt"] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "text": text,
      "senderId": senderId,
      "type": enumToString(type),
      "createdAt": createdAt,
    };
  }
}

/// Represents an individual message within a chat conversation.
class MessageModel {
  final String id;
  final String senderId;
  final MessageType type;
  final String text;

  /// Attached media or files (images, videos, etc.)
  final List<AssetModel> assets;

  /// Map of userId to boolean representing read/seen status
  final Map<String, bool> readBy;
  final int createdAt;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.type,
    required this.text,
    required this.assets,
    required this.readBy,
    required this.createdAt,
  });

  factory MessageModel.fromMap(Map<String, dynamic> data) {
    return MessageModel(
      id: data["id"] ?? "",
      senderId: data["senderId"] ?? "",
      type: enumFromString(
        MessageType.values,
        data["type"],
        MessageType.text,
      ),
      text: data["text"] ?? "",
      assets: (data["assets"] as List? ?? [])
          .map<AssetModel>(
              (e) => AssetModel.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      readBy: Map<String, bool>.from(data["readBy"] ?? {}),
      createdAt: data["createdAt"] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "senderId": senderId,
      "type": enumToString(type),
      "text": text,
      "assets": assets.map((e) => e.toMap()).toList(),
      "readBy": readBy,
      "createdAt": createdAt,
    };
  }

  MessageModel copyWith({
    String? id,
    String? senderId,
    MessageType? type,
    String? text,
    List<AssetModel>? assets,
    Map<String, bool>? readBy,
    int? createdAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      type: type ?? this.type,
      text: text ?? this.text,
      assets: assets ?? this.assets,
      readBy: readBy ?? this.readBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Represents a media file or attachment associated with a message.
class AssetModel {
  final String id;
  final String type; // e.g., 'image/png', 'video/mp4'
  final String url;

  final String? thumbnail;
  final int? width;
  final int? height;
  final int? duration; // Duration in seconds for audio/video
  final int? size; // File size in bytes
  final String? name; // Original filename

  AssetModel({
    required this.id,
    required this.type,
    required this.url,
    this.thumbnail,
    this.width,
    this.height,
    this.duration,
    this.size,
    this.name,
  });

  factory AssetModel.fromMap(Map<String, dynamic> data) {
    return AssetModel(
      id: data["id"] ?? "",
      type: data["type"] ?? "",
      url: data["url"] ?? "",
      thumbnail: data["thumbnail"],
      width: data["width"],
      height: data["height"],
      duration: data["duration"],
      size: data["size"],
      name: data["name"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "type": type,
      "url": url,
      "thumbnail": thumbnail,
      "width": width,
      "height": height,
      "duration": duration,
      "size": size,
      "name": name,
    };
  }
}
