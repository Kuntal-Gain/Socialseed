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
  final List? followers;
  final List? following;
  final List? requests;
  final List? milestones;
  final List? likedPages;
  final List? posts;
  final Timestamp? joinedDate;
  final Timestamp? dob;
  final bool? isVerified;
  final List? badges;
  final num? followerCount;
  final num? followingCount;
  final List? stories;
  final String? work;
  final String? college;
  final String? school;
  final String? location;
  final String? coverImage;
  final bool? activeStatus;
  final List? messages;
  final Timestamp? lastSeen;
  final List? savedContent;
  final List? archivedContent;

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
    this.work,
    this.college,
    this.school,
    this.location,
    this.coverImage,
    this.dob,
    this.followers,
    this.following,
    this.requests,
    this.activeStatus,
    this.messages,
    this.lastSeen,
    this.savedContent,
    this.archivedContent,
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
          work: work,
          college: college,
          school: school,
          location: location,
          coverImage: coverImage,
          dob: dob,
          followers: followers,
          following: following,
          requests: requests,
          activeStatus: activeStatus,
          messages: messages,
          lastSeen: lastSeen,
          savedContent: savedContent,
          archivedContent: archivedContent,
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
      work: ss["work"],
      college: ss["college"],
      school: ss["school"],
      location: ss["location"],
      coverImage: ss["coverImage"],
      dob: ss["dob"],
      followers: ss['followers'],
      following: ss['following'],
      requests: ss['requests'],
      activeStatus: ss['active_status'],
      messages: ss['messages'],
      lastSeen: ss['last_seen'],
      archivedContent: ss['archivedContent'],
      savedContent: ss['savedContent'],
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
        "work": work,
        "college": college,
        "school": school,
        "location": location,
        "coverImage": coverImage,
        "dob": dob,
        "following": following,
        "followers": followers,
        "requests": requests,
        "active_status": activeStatus,
        "messages": messages,
        "last_seen": lastSeen,
        "archivedContent": archivedContent,
        "savedContent": savedContent,
      };
}
