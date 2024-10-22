// ignore_for_file: annotate_overrides, overridden_fields, duplicate_ignore

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialseed/domain/entities/post_entity.dart';

class PostModel extends PostEntity {
  // ignore: overridden_fields
  final String? postid;
  final String? uid;
  final String? username;
  final String? postType;
  final String? content;
  final List? images;
  final List? likes;
  final List? likedUsers;
  final List? comments;
  final num? totalLikes;
  final num? totalComments;
  final num? shares;
  final String? location;
  final List? tags;
  final Timestamp? creationDate;
  final String? profileId;
  final bool? isVerified;
  final String? work;
  final String? college;
  final String? school;
  final String? home;

  const PostModel({
    this.postid,
    this.uid,
    this.username,
    this.postType,
    this.content,
    this.images,
    this.likes,
    this.comments,
    this.totalLikes,
    this.totalComments,
    this.shares,
    this.location,
    this.tags,
    this.creationDate,
    this.profileId,
    this.isVerified,
    this.home,
    this.college,
    this.school,
    this.work,
    this.likedUsers,
  }) : super(
          postid: postid,
          uid: uid,
          username: username,
          postType: postType,
          content: content,
          images: images,
          likes: likes,
          comments: comments,
          totalLikes: totalComments,
          totalComments: totalComments,
          shares: shares,
          location: location,
          tags: tags,
          creationDate: creationDate,
          profileId: profileId,
          isVerified: isVerified,
          home: home,
          work: work,
          college: college,
          school: school,
          likedUsers: likedUsers,
        );

  factory PostModel.fromSnapShot(DocumentSnapshot snap) {
    var ss = snap.data() as Map<String, dynamic>;

    return PostModel(
      postid: ss['postid'],
      uid: ss['uid'],
      username: ss['username'],
      postType: ss['postType'],
      content: ss['content'],
      images: List.from(snap.get('images')),
      likes: List.from(snap.get('likes')),
      likedUsers: List.from(snap.get('likedUsers')),
      comments: List.from(snap.get('comments')),
      totalLikes: ss['totalLikes'],
      totalComments: ss['totalComments'],
      shares: ss['shares'],
      location: ss['location'],
      tags: List.from(snap.get('tags')),
      creationDate: ss['creationDate'],
      profileId: ss['profileId'],
      isVerified: ss['isVerified'],
      work: ss['work'],
      college: ss['college'],
      school: ss['school'],
      home: ss['home'],
    );
  }

  Map<String, dynamic> toJson() => {
        "postid": postid,
        "uid": uid,
        "username": username,
        "postType": postType,
        "content": content,
        "images": images,
        "likes": likes,
        "comments": comments,
        "totalLikes": totalLikes, // Correctly use totalLikes here
        "totalComments": totalComments,
        "shares": shares,
        "location": location,
        "tags": tags,
        "creationDate": creationDate,
        "profileId": profileId,
        'isVerified': isVerified,
        "home": home,
        "work": work,
        "college": college,
        "school": school,
        "likedUsers": likedUsers, // Ensure likedUsers is included
      };
}
