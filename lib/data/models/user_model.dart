// ignore_for_file: annotate_overrides, overridden_fields

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialseed/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  final String? uid;
  final String? username;
  final String? fullname;
  final String? email;
  final String? bio;
  final String? imageUrl;
  final List? friends;
  final List? milestones;
  final List? likedPages;
  final List? posts;
  final Timestamp? joinedDate;
  final bool? isVerified;
  final List? badges;
  final num? followerCount;
  final num? followingCount;
  final List? stories;

  const UserModel({
    this.uid,
    this.username,
    this.fullname,
    this.email,
    this.bio,
    this.imageUrl,
    this.friends,
    this.milestones,
    this.likedPages,
    this.posts,
    this.joinedDate,
    this.isVerified,
    this.badges,
    this.followerCount,
    this.followingCount,
    this.stories,
  }) : super(
          uid: uid,
          username: username,
          fullname: fullname,
          email: email,
          bio: bio,
          imageUrl: imageUrl,
          friends: friends,
          milestones: milestones,
          likedPages: likedPages,
          posts: posts,
          joinedDate: joinedDate,
          isVerified: isVerified,
          badges: badges,
          followerCount: followerCount,
          followingCount: followingCount,
          stories: stories,
        );

  factory UserModel.fromSnapShot(DocumentSnapshot snap) {
    var ss = snap.data() as Map<String, dynamic>;

    return UserModel(
      uid: ss['uid'],
      username: ss['username'],
      fullname: ss['fullname'],
      email: ss['email'],
      bio: ss['bio'],
      imageUrl: ss['imageUrl'],
      friends: ss['friends'],
      milestones: ss['milestones'],
      likedPages: ss['likedPages'],
      posts: ss['posts'],
      joinedDate: ss['joinedDate'],
      isVerified: ss['isVerified'],
      badges: ss['badges'],
      followerCount: ss['followerCount'],
      followingCount: ss['followingCount'],
      stories: ss['stories'],
    );
  }

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "username": username,
        "fullname": fullname,
        "email": email,
        "bio": bio,
        "imageUrl": imageUrl,
        "friends": friends,
        "milestones": milestones,
        "likedPages": likedPages,
        "posts": posts,
        "joinedDate": joinedDate,
        "isVerified": isVerified,
        "badges": badges,
        "followerCount": followerCount,
        "followingCount": followingCount,
        "stories": stories,
      };
}
