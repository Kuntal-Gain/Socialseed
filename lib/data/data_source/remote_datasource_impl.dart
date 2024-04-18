// ignore_for_file: avoid_print, curly_braces_in_flow_control_structures, unrelated_type_equality_checks

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:socialseed/data/data_source/remote_datasource.dart';
import 'package:socialseed/data/models/comment_model.dart';
import 'package:socialseed/data/models/post_model.dart';
import 'package:socialseed/data/models/user_model.dart';
import 'package:socialseed/domain/entities/comment_entity.dart';
import 'package:socialseed/domain/entities/post_entity.dart';
import 'package:socialseed/domain/entities/user_entity.dart';
import 'package:socialseed/utils/constants/color_const.dart';
import 'package:socialseed/utils/constants/firebase_const.dart';
import 'package:uuid/uuid.dart';

class RemoteDataSourceImpl implements RemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;

  RemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firebaseFirestore,
  });

  @override
  Future<void> createUser(UserEntity user) async {
    final userCollection = firebaseFirestore.collection(FirebaseConst.users);

    final uid = await getCurrentUid();

    userCollection.doc(uid).get().then((newDoc) {
      final newUser = UserModel(
        uid: uid,
        username: user.username,
        fullname: user.fullname,
        email: user.email,
        bio: user.bio,
        imageUrl: user.imageUrl,
        friends: user.friends,
        milestones: user.milestones,
        likedPages: user.likedPages,
        posts: user.posts,
        joinedDate: user.joinedDate,
        isVerified: user.isVerified,
        badges: user.badges,
        followerCount: user.followerCount,
        followingCount: user.followingCount,
        stories: user.stories,
      ).toJson();

      if (!newDoc.exists) {
        userCollection.doc(uid).set(newUser);
      } else {
        userCollection.doc(uid).update(newUser);
      }
    }).catchError((err) {
      print(err.toString());
    });
  }

  @override
  Future<String> getCurrentUid() async => firebaseAuth.currentUser!.uid;

  @override
  Stream<List<UserEntity>> getSingleUsers(String uid) {
    final userCollection = firebaseFirestore
        .collection(FirebaseConst.users)
        .where("uid", isEqualTo: uid)
        .limit(1);
    return userCollection.snapshots().map((querySnapshot) =>
        querySnapshot.docs.map((e) => UserModel.fromSnapShot(e)).toList());
  }

  @override
  Stream<List<UserEntity>> getUsers(UserEntity user) {
    throw UnimplementedError();
  }

  @override
  Future<bool> isSignIn() async => firebaseAuth.currentUser?.uid != null;

  @override
  Future<void> signInUser(UserEntity user, BuildContext context) async {
    try {
      if (user.email!.isNotEmpty || user.password!.isNotEmpty) {
        await firebaseAuth.signInWithEmailAndPassword(
          email: user.email!,
          password: user.password!,
        );

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Login Successfull',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
          'User Not Exist',
        )));
      } else if (e.code == 'wrong-password') {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
          'Password Is Wrong , Try Again',
        )));
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
          'Something Went Wrong',
        )));
      }
    }
  }

  @override
  Future<void> signOut() async => await firebaseAuth.signOut();

  @override
  Future<void> signUpUser(UserEntity user, BuildContext context) async {
    try {
      if (user.email!.isNotEmpty || user.password!.isNotEmpty) {
        await firebaseAuth
            .createUserWithEmailAndPassword(
          email: user.email!,
          password: user.password!,
        )
            .then((value) async {
          if (value.user?.uid != null) {
            await createUser(user);
          }
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Account Creation Successfull',
              ),
              backgroundColor: Colors.green,
            ),
          );
        });

        return;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            'User Already Exists',
          ),
          backgroundColor: AppColor.redColor,
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'Something Went wrong (${e.code})',
          ),
          backgroundColor: AppColor.redColor,
        ));
      }
    }
  }

  @override
  Future<void> updateUser(UserEntity user) async {
    final userCollection = firebaseFirestore.collection(FirebaseConst.users);

    // ignore: prefer_collection_literals
    Map<String, dynamic> userInformation = Map();

    if (user.username != "" && user.username != null)
      userInformation['username'] = user.username;
    if (user.fullname != "" && user.fullname != null)
      userInformation['fullname'] = user.fullname;
    if (user.email != "" && user.email != null)
      userInformation['email'] = user.email;
    if (user.bio != "" && user.bio != null) userInformation['bio'] = user.bio;
    if (user.imageUrl != "" && user.imageUrl != null)
      userInformation['imageUrl'] = user.imageUrl;
    if (user.friends != "" && user.friends != null)
      userInformation['friends'] = user.friends;
    if (user.milestones != "" && user.milestones != null)
      userInformation['milestones'] = user.milestones;
    if (user.likedPages != "" && user.likedPages != null)
      userInformation['likedPages'] = user.likedPages;
    if (user.posts != "" && user.posts != null)
      userInformation['posts'] = user.posts;
    if (user.username != "" && user.username != null)
      userInformation['username'] = user.username;
    if (user.followerCount != "" && user.followerCount != null)
      userInformation['followerCount'] = user.followerCount;
    if (user.followingCount != "" && user.followingCount != null)
      userInformation['followingCount'] = user.followingCount;

    userCollection.doc(user.uid).update(userInformation);
  }

  @override
  Future<String?> uploadImageToStorage(
      File? file, bool isPost, String child) async {
    Reference ref = FirebaseStorage.instance
        .ref()
        .child(child)
        .child(firebaseAuth.currentUser!.uid);

    if (isPost) {
      String id = const Uuid().v1();
      ref = ref.child(id);

      final uploadTask = ref.putFile(file!);

      final imageUrl =
          (await uploadTask.whenComplete(() {})).ref.getDownloadURL();

      return await imageUrl;
    }
    return null;
  }

  @override
  Future<void> createPost(PostEntity post) async {
    final postCollection = firebaseFirestore.collection(FirebaseConst.posts);

    final newPost = PostModel(
      postid: post.postid,
      uid: post.uid,
      username: post.username,
      postType: post.postType,
      content: post.content,
      images: post.images,
      likes: const [],
      comments: const [],
      totalLikes: 0,
      totalComments: 0,
      shares: 0,
      location: post.location,
      tags: post.tags,
      creationDate: post.creationDate,
      profileId: post.profileId,
    ).toJson();

    try {
      final postRef = await postCollection.doc(post.postid).get();

      if (!postRef.exists) {
        postCollection.doc(post.postid).set(newPost);
      } else {
        postCollection.doc(post.postid).update(newPost);
      }
    } catch (_) {
      debugPrint('Something went wrong');
    }
  }

  @override
  Future<void> deletePost(PostEntity post) async {
    final postCollection = firebaseFirestore.collection(FirebaseConst.posts);

    try {
      postCollection.doc(post.postid).delete();
    } catch (_) {
      debugPrint('something went wrong');
    }
  }

  @override
  Stream<List<PostEntity>> fetchPost(PostEntity post) {
    final postCollection = firebaseFirestore
        .collection(FirebaseConst.posts)
        .orderBy("creationDate", descending: true);

    return postCollection.snapshots().map((querySnapshot) =>
        querySnapshot.docs.map((e) => PostModel.fromSnapShot(e)).toList());
  }

  @override
  Future<void> likePost(PostEntity post) async {
    final postCollection = firebaseFirestore.collection(FirebaseConst.posts);

    final currentUid = await getCurrentUid();

    final postRef = await postCollection.doc(post.postid).get();

    if (postRef.exists) {
      List likes = postRef.get('likes');
      final totalLikes = postRef.get("totalLikes");
      if (likes.contains(currentUid)) {
        postCollection.doc(post.postid).update({
          "likes": FieldValue.arrayRemove([currentUid]),
          "totalLikes": totalLikes - 1
        });
      } else {
        postCollection.doc(post.postid).update({
          "likes": FieldValue.arrayUnion([currentUid]),
          "totalLikes": totalLikes + 1
        });
      }
    }
  }

  @override
  Future<void> updatePost(PostEntity post) async {
    final postCollection = firebaseFirestore.collection(FirebaseConst.posts);
    Map<String, dynamic> postInfo = {};

    // Populate the postInfo map with updated content and images
    if (post.content != null && post.content!.isNotEmpty) {
      postInfo['content'] = post.content;
    }

    try {
      // Attempt to update the document
      await postCollection.doc(post.postid).update(postInfo);
    } catch (e) {
      // Handle error cases (e.g., document not found, permissions issues)
      print("Error updating post: $e");
      // You can add more specific error handling here if needed
    }
  }

  @override
  Stream<List<PostEntity>> fetchSinglePost(String postId) {
    final postCollection = firebaseFirestore
        .collection(FirebaseConst.posts)
        .orderBy("creationDate", descending: true)
        .where("postid", isEqualTo: postId);
    return postCollection.snapshots().map((querySnapshot) =>
        querySnapshot.docs.map((e) => PostModel.fromSnapShot(e)).toList());
  }

  @override
  Future<void> createComment(CommentEntity comment) async {
    final commentCollection = firebaseFirestore
        .collection(FirebaseConst.posts)
        .doc(comment.postId)
        .collection(FirebaseConst.comments);

    final newComment = CommentModel(
      profileUrl: comment.profileUrl,
      username: comment.username,
      commentId: comment.commentId,
      postId: comment.postId,
      likes: [],
      content: comment.content,
      creatorUid: comment.creatorUid,
      createAt: comment.createAt,
    ).toJson();

    try {
      final commentRef = await commentCollection.doc(comment.commentId).get();

      if (!commentRef.exists) {
        commentCollection.doc(comment.commentId).set(newComment).then((value) {
          final postCollection = firebaseFirestore
              .collection(FirebaseConst.posts)
              .doc(comment.postId);

          postCollection.get().then((value) {
            if (value.exists) {
              final totalComments = value.get('totalComments');
              postCollection.update({"totalComments": totalComments + 1});
              return;
            } else {
              commentCollection.doc(comment.commentId).update(newComment);
            }
          });
        });
      }
    } catch (e) {
      print("some error occured $e");
    }
  }

  @override
  Future<void> deleteComment(CommentEntity comment) async {
    final commentCollection = firebaseFirestore
        .collection(FirebaseConst.posts)
        .doc(comment.postId)
        .collection(FirebaseConst.comments);

    try {
      commentCollection.doc(comment.commentId).delete().then((value) {
        final postCollection = firebaseFirestore
            .collection(FirebaseConst.posts)
            .doc(comment.postId);

        postCollection.get().then((value) {
          if (value.exists) {
            final totalComments = value.get('totalComments');
            postCollection.update({"totalComments": totalComments - 1});
            return;
          }
        });
      });
    } catch (e) {
      print("some error occured $e");
    }
  }

  @override
  Stream<List<CommentEntity>> fetchComments(String postId) {
    final commentCollection = firebaseFirestore
        .collection(FirebaseConst.posts)
        .doc(postId)
        .collection(FirebaseConst.comments)
        .orderBy("createAt", descending: true);
    return commentCollection.snapshots().map((querySnapshot) =>
        querySnapshot.docs.map((e) => CommentModel.fromSnapshot(e)).toList());
  }

  @override
  Future<void> likeComment(CommentEntity comment) async {
    final commentCollection = firebaseFirestore
        .collection(FirebaseConst.posts)
        .doc(comment.postId)
        .collection(FirebaseConst.comments);
    final currentUid = await getCurrentUid();

    final commentRef = await commentCollection.doc(comment.commentId).get();

    if (commentRef.exists) {
      List likes = commentRef.get("likes");
      if (likes.contains(currentUid)) {
        commentCollection.doc(comment.commentId).update({
          "likes": FieldValue.arrayRemove([currentUid])
        });
      } else {
        commentCollection.doc(comment.commentId).update({
          "likes": FieldValue.arrayUnion([currentUid])
        });
      }
    }
  }

  @override
  Future<void> updateComment(CommentEntity comment) async {
    final commentCollection = firebaseFirestore
        .collection(FirebaseConst.posts)
        .doc(comment.postId)
        .collection(FirebaseConst.comments);

    Map<String, dynamic> commentInfo = Map();

    if (comment.content != "" && comment.content != null)
      commentInfo["content"] = comment.content;

    commentCollection.doc(comment.commentId).update(commentInfo);
  }
}
