import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageEntity extends Equatable {
  final String? message;
  final String? senderId;
  final Timestamp? createAt;

  const MessageEntity({
    required this.message,
    required this.createAt,
    required this.senderId,
  });

  @override
  List<Object?> get props => [message, createAt, senderId];
}
