import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserEntity extends Equatable {
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

  // not gonna stored into DB
  final File? imageFile;
  final String? password;
  final String? otherUid;

  const UserEntity({
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
    this.password,
    this.otherUid,
    this.imageFile,
  });

  @override
  List<Object?> get props => [
        uid,
        username,
        fullname,
        email,
        bio,
        imageUrl,
        friends,
        milestones,
        likedPages,
        posts,
        joinedDate,
        isVerified,
        badges,
        followerCount,
        followingCount,
        stories,
        password,
        otherUid,
        imageFile,
      ];
}
