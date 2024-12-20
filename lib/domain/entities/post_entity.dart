import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class PostEntity extends Equatable {
  // unique id
  final String? postid;
  final String? uid;
  final String? username;
  final String? profileId;
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
  final bool? isVerified;
  final String? work;
  final String? college;
  final String? school;
  final String? home;

  const PostEntity({
    this.postid,
    this.uid,
    this.username,
    this.postType,
    this.content,
    this.images,
    this.likes,
    this.comments,
    this.shares,
    this.location,
    this.tags,
    this.totalLikes,
    this.totalComments,
    this.creationDate,
    this.profileId,
    this.isVerified,
    this.college,
    this.school,
    this.work,
    this.home,
    this.likedUsers,
  });

  @override
  List<Object?> get props => [
        postid,
        uid,
        postType,
        content,
        username,
        images,
        likes,
        comments,
        shares,
        location,
        tags,
        totalLikes,
        totalComments,
        creationDate,
        profileId,
        isVerified,
        home,
        school,
        college,
        work,
        likedUsers,
      ];
}
