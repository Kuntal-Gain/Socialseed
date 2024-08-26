import 'dart:io';

import 'package:flutter/material.dart';
import 'package:socialseed/data/data_source/remote_datasource.dart';
import 'package:socialseed/domain/entities/chat_entity.dart';
import 'package:socialseed/domain/entities/comment_entity.dart';
import 'package:socialseed/domain/entities/message_entity.dart';
import 'package:socialseed/domain/entities/post_entity.dart';
import 'package:socialseed/domain/entities/story_entity.dart';
import 'package:socialseed/domain/entities/user_entity.dart';
import 'package:socialseed/domain/repos/firebase_repository.dart';

class FirebaseRepositoryImpl implements FirebaseRepository {
  final RemoteDataSource remoteDataSource;

  FirebaseRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> createUser(UserEntity user) async =>
      remoteDataSource.createUser(user);

  @override
  Future<String> getCurrentUid() async => remoteDataSource.getCurrentUid();

  @override
  Stream<List<UserEntity>> getSingleUsers(String uid) =>
      remoteDataSource.getSingleUsers(uid);

  @override
  Stream<List<UserEntity>> getUsers(UserEntity user) =>
      remoteDataSource.getUsers(user);

  @override
  Future<bool> isSignIn() async => remoteDataSource.isSignIn();

  @override
  Future<void> signInUser(UserEntity user, BuildContext ctx) async =>
      remoteDataSource.signInUser(user, ctx);

  @override
  Future<void> signOut() async => remoteDataSource.signOut();

  @override
  Future<void> signUpUser(UserEntity user, BuildContext ctx) async =>
      remoteDataSource.signUpUser(user, ctx);

  @override
  Future<void> updateUser(UserEntity user) async =>
      remoteDataSource.updateUser(user);

  @override
  Future<String?> uploadImageToStorage(
          File? file, bool isPost, String child) async =>
      remoteDataSource.uploadImageToStorage(file, isPost, child);

  @override
  Future<void> createPost(PostEntity post) async =>
      remoteDataSource.createPost(post);

  @override
  Future<void> deletePost(PostEntity post) async =>
      remoteDataSource.deletePost(post);

  @override
  Stream<List<PostEntity>> fetchPost(PostEntity post) =>
      remoteDataSource.fetchPost(post);

  @override
  Future<void> likePost(PostEntity post) async =>
      remoteDataSource.likePost(post);

  @override
  Future<void> updatePost(PostEntity post) async =>
      remoteDataSource.updatePost(post);

  @override
  Stream<List<PostEntity>> fetchSinglePost(String postId) =>
      remoteDataSource.fetchSinglePost(postId);

  @override
  Future<void> createComment(CommentEntity comment) async =>
      remoteDataSource.createComment(comment);

  @override
  Future<void> deleteComment(CommentEntity comment) async =>
      remoteDataSource.deleteComment(comment);

  @override
  Stream<List<CommentEntity>> fetchComments(String postId) =>
      remoteDataSource.fetchComments(postId);

  @override
  Future<void> likeComment(CommentEntity comment) async =>
      remoteDataSource.likeComment(comment);

  @override
  Future<void> updateComment(CommentEntity comment) async =>
      remoteDataSource.updateComment(comment);

  @override
  Stream<List<PostEntity>> fetchPostByUid(String uid) =>
      remoteDataSource.fetchPostByUid(uid);

  @override
  Stream<List<UserEntity>> getSingleOtherUser(String otherUid) =>
      remoteDataSource.getSingleOtherUser(otherUid);

  @override
  Future<void> acceptRequest(UserEntity user) async =>
      remoteDataSource.acceptRequest(user);

  @override
  Future<void> followUser(UserEntity user) async =>
      remoteDataSource.followUser(user);

  @override
  Future<void> sendRequest(UserEntity user) async =>
      remoteDataSource.sendRequest(user);

  @override
  Future<void> unfollowUser(UserEntity user) async =>
      remoteDataSource.unfollowUser(user);

  @override
  Future<void> rejectRequest(UserEntity user) async =>
      remoteDataSource.rejectRequest(user);

  @override
  Stream<List<MessageEntity>> fetchMessages(String messageId) =>
      remoteDataSource.fetchMessages(messageId);

  @override
  Future<void> sendMessage(String messageId, String msg) async =>
      remoteDataSource.sendMessage(messageId, msg);

  @override
  Future<void> createMessageWithId(ChatEntity chat) async =>
      remoteDataSource.createMessageWithId(chat);

  @override
  Stream<List<ChatEntity>> fetchConversations() =>
      remoteDataSource.fetchConversations();

  @override
  Future<bool> isMessageIdExists(String messageId) =>
      remoteDataSource.isMessageIdExists(messageId);

  @override
  Future<void> addStory(StoryEntity story) async =>
      remoteDataSource.addStory(story);

  @override
  Stream<List<StoryEntity>> fetchStories(String uid) =>
      remoteDataSource.fetchStories(uid);

  @override
  Future<void> viewStory(StoryEntity story) async =>
      remoteDataSource.viewStory(story);
}
