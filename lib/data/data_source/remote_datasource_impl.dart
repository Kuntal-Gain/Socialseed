// ignore_for_file: avoid_print, curly_braces_in_flow_control_structures, unrelated_type_equality_checks

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:socialseed/data/data_source/remote_datasource.dart';
import 'package:socialseed/data/models/chat_model.dart';
import 'package:socialseed/data/models/comment_model.dart';

import 'package:socialseed/data/models/post_model.dart';
import 'package:socialseed/data/models/user_model.dart';
import 'package:socialseed/domain/entities/chat_entity.dart';
import 'package:socialseed/domain/entities/comment_entity.dart';
import 'package:socialseed/domain/entities/message_entity.dart';
import 'package:socialseed/domain/entities/post_entity.dart';
import 'package:socialseed/domain/entities/user_entity.dart';
import 'package:socialseed/utils/constants/color_const.dart';
import 'package:socialseed/utils/constants/firebase_const.dart';
import 'package:uuid/uuid.dart';

import '../models/message_model.dart';

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
        work: user.work,
        college: user.college,
        school: user.school,
        location: user.location,
        coverImage: user.coverImage,
        dob: user.dob,
        followers: user.followers,
        following: user.following,
        requests: user.requests,
        activeStatus: user.activeStatus,
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
    final userCollection = firebaseFirestore.collection(FirebaseConst.users);
    return userCollection.snapshots().map((querySnapshot) =>
        querySnapshot.docs.map((e) => UserModel.fromSnapShot(e)).toList());
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

        final uid = await getCurrentUid();

        await firebaseFirestore
            .collection(FirebaseConst.users)
            .doc(uid)
            .update({
          "active_status": true,
        });

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
  Future<void> signOut() async {
    final user = firebaseAuth.currentUser;
    if (user != null) {
      await firebaseFirestore
          .collection(FirebaseConst.users)
          .doc(user.uid)
          .update({
        'active_status': false,
      });
      await firebaseAuth.signOut();
    }
  }

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

    if (user.work != "" && user.work != null)
      userInformation['work'] = user.work;

    if (user.college != "" && user.college != null)
      userInformation['college'] = user.college;

    if (user.school != "" && user.school != null)
      userInformation['school'] = user.school;

    if (user.location != "" && user.location != null)
      userInformation['location'] = user.location;

    if (user.coverImage != "" && user.coverImage != null)
      userInformation['coverImage'] = user.coverImage;

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
    final userCollection = firebaseFirestore.collection(FirebaseConst.users);

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
      isVerified: post.isVerified,
      work: post.work,
      college: post.college,
      school: post.school,
      home: post.home,
    ).toJson();

    try {
      final postRef = await postCollection.doc(post.postid).get();
      final userRef = await userCollection.doc(post.uid).get();

      if (!postRef.exists) {
        postCollection.doc(post.postid).set(newPost);
      } else {
        postCollection.doc(post.postid).update(newPost);
      }

      if (userRef.exists) {
        userRef.get("posts");
        final postId = post.postid;

        userCollection.doc(post.uid).update({
          "posts": FieldValue.arrayUnion([postId]),
        });
      }
    } catch (_) {
      debugPrint('Something went wrong');
    }
  }

  @override
  Future<void> deletePost(PostEntity post) async {
    final postCollection = firebaseFirestore.collection(FirebaseConst.posts);
    final userCollection = firebaseFirestore.collection(FirebaseConst.users);

    try {
      postCollection.doc(post.postid).delete();
      userCollection.doc(post.uid).update({
        "posts": FieldValue.arrayRemove([post.postid])
      });
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
    final userCollection = firebaseFirestore
        .collection(FirebaseConst.users); // Access the user collection

    final currentUid = await getCurrentUid();
    final postRef = await postCollection.doc(post.postid).get();

    if (postRef.exists) {
      List likes = postRef.get('likes');
      final totalLikes = postRef.get("totalLikes");

      // Fetch the current user's username
      final currentUserDoc = await userCollection.doc(currentUid).get();
      String currentUsername = "";
      if (currentUserDoc.exists) {
        currentUsername = currentUserDoc.get('username');
      }

      if (likes.contains(currentUid)) {
        await postCollection.doc(post.postid).update({
          "likes": FieldValue.arrayRemove([currentUid]),
          "totalLikes": totalLikes - 1
        });
      } else {
        await postCollection.doc(post.postid).update({
          "likes": FieldValue.arrayUnion([currentUid]),
          "totalLikes": totalLikes + 1
        });

        // Add notification
        await userCollection
            .doc(post
                .uid) // Assuming the creator's UID is stored in post.creatorId
            .collection('notifications')
            .add({
          "message": "$currentUsername liked your post",
          "createdAt": FieldValue.serverTimestamp(),
          "postId": post.postid,
          "type": "like"
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
      likes: const [],
      content: comment.content,
      creatorUid: comment.creatorUid,
      createAt: comment.createAt,
    ).toJson();

    try {
      final commentRef = await commentCollection.doc(comment.commentId).get();

      if (!commentRef.exists) {
        await commentCollection.doc(comment.commentId).set(newComment);
        final postCollection = firebaseFirestore
            .collection(FirebaseConst.posts)
            .doc(comment.postId);

        final postSnapshot = await postCollection.get();

        if (postSnapshot.exists) {
          final totalComments = postSnapshot.get('totalComments') ?? 0;
          await postCollection.update({"totalComments": totalComments + 1});

          // Fetch the post creator's ID
          final postCreatorId = postSnapshot.get('uid');

          // Fetch the current user's username
          final userCollection =
              firebaseFirestore.collection(FirebaseConst.users);
          final currentUid = await getCurrentUid();
          final currentUserDoc = await userCollection.doc(currentUid).get();
          String currentUsername = "";
          if (currentUserDoc.exists) {
            currentUsername = currentUserDoc.get('username');
          }

          // Add notification
          await userCollection
              .doc(postCreatorId)
              .collection('notifications')
              .add({
            "message": "$currentUsername commented on your post",
            "createdAt": FieldValue.serverTimestamp(),
            "postId": comment.postId,
            "commentId": comment.commentId,
            "type": "comment"
          });

          // Log or debug print before sending notification
          debugPrint('Sending comment notification');
        } else {
          // If the post doesn't exist, log an error
          debugPrint('Post does not exist');
        }
      } else {
        debugPrint('Comment already exists');
      }
    } catch (e) {
      debugPrint("Error in createComment: $e");
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

    Map<String, dynamic> commentInfo = {};

    if (comment.content != "" && comment.content != null)
      commentInfo["content"] = comment.content;

    commentCollection.doc(comment.commentId).update(commentInfo);
  }

  @override
  Stream<List<PostEntity>> fetchPostByUid(String uid) {
    final postCollection = firebaseFirestore
        .collection(FirebaseConst.posts)
        .where("uid", isEqualTo: uid)
        .orderBy("creationDate", descending: true);

    return postCollection.snapshots().map((querySnapshot) =>
        querySnapshot.docs.map((e) => PostModel.fromSnapShot(e)).toList());
  }

  @override
  Stream<List<UserEntity>> getSingleOtherUser(String otherUid) {
    final userCollection = firebaseFirestore
        .collection(FirebaseConst.users)
        .where("uid", isEqualTo: otherUid)
        .limit(1);
    return userCollection.snapshots().map((querySnapshot) =>
        querySnapshot.docs.map((e) => UserModel.fromSnapShot(e)).toList());
  }

  @override
  Future<void> acceptRequest(UserEntity user) async {
    final userCollection = firebaseFirestore.collection(FirebaseConst.users);
    final currentUid = await getCurrentUid();

    final targetUserRef = await userCollection.doc(currentUid).get();
    // final requesterRef = await userCollection.doc(user.uid).get();

    if (targetUserRef.exists) {
      List requests = targetUserRef.get('requests');

      if (requests.contains(user.uid)) {
        userCollection.doc(currentUid).update({
          "requests": FieldValue.arrayRemove([user.uid]),
          "friends": FieldValue.arrayUnion([user.uid]),
        });

        userCollection.doc(user.uid).update({
          "friends": FieldValue.arrayUnion([currentUid]),
        });
      }
    }
  }

  @override
  Future<void> followUser(UserEntity user) async {
    final userCollection = firebaseFirestore.collection(FirebaseConst.users);
    final currentUid = await getCurrentUid();

    // Fetch the current user's username
    final currentUserSnapshot = await userCollection.doc(currentUid).get();
    final currentUsername = currentUserSnapshot.get('username') as String?;
    final currentImage = currentUserSnapshot.get('imageUrl') as String?;

    final targetUserRef = userCollection.doc(user.uid);
    final currentUserRef = userCollection.doc(currentUid);

    try {
      // Fetch target user's document
      final targetUserSnapshot = await targetUserRef.get();
      final List followers = targetUserSnapshot.get('followers') ?? [];

      // Check if the current user is already following the target user
      if (followers.contains(currentUid)) {
        print('User is already following this user');
        return;
      }

      // Create or update target user's document with "followers" field and initialize followerCount if not exists
      await targetUserRef.set({
        'followers':
            FieldValue.arrayUnion([]), // Ensures 'followers' field exists
        'followerCount': FieldValue.increment(0),
        'followingCount': FieldValue.increment(0),
      }, SetOptions(merge: true));

      // Add current user's UID to target user's "followers" array and increment followerCount
      await targetUserRef.update({
        'followers': FieldValue.arrayUnion([currentUid]),
        'followerCount': FieldValue.increment(1),
      });

      // Add target user's UID to current user's "following" array and increment followingCount
      await currentUserRef.update({
        'following': FieldValue.arrayUnion([user.uid]),
        'followingCount': FieldValue.increment(1),
      });

      // Create a notification for the target user
      final notificationCollection = targetUserRef.collection('notifications');
      await notificationCollection.add({
        'message': '$currentUsername started following you!',
        'createdAt': FieldValue.serverTimestamp(),
        'type': 'follow',
        'userId': currentImage,
      });

      print('Follow and notification added successfully');
    } catch (e) {
      print("Error following user: $e");
    }
  }

  @override
  Future<void> sendRequest(UserEntity user) async {
    final userCollection = firebaseFirestore.collection(FirebaseConst.users);
    final currentUid = await getCurrentUid();

    final targetUserRef = userCollection.doc(user.uid);

    try {
      final targetUserDoc = await targetUserRef.get();

      if (targetUserDoc.exists) {
        // Retrieve current requests or initialize an empty list
        List requests = targetUserDoc.data()?['requests'] ?? [];

        if (!requests.contains(currentUid)) {
          // Add current user's UID to requests list
          requests.add(currentUid);
          // Update the document with the new requests list
          await targetUserRef.update({'requests': requests});

          // Add notification for the target user
          await targetUserRef.collection('notifications').add({
            'type': 'friend_request',
            'message': 'You have a new friend request.',
            'userId': currentUid, // Assuming this is the image URL
            'createdAt': FieldValue.serverTimestamp(),
          });
        } else {
          requests.remove(currentUid);
          await targetUserRef.update({'requests': requests});

          // Optionally, remove the friend request notification
          final notificationsQuery = await targetUserRef
              .collection('notifications')
              .where('type', isEqualTo: 'friend_request')
              .where('userId', isEqualTo: currentUid)
              .get();

          for (var doc in notificationsQuery.docs) {
            await doc.reference.delete();
          }
        }
      } else {
        // If the document doesn't exist, create it with requests list containing current user's UID
        await targetUserRef.set({
          'requests': [currentUid]
        });

        // Add notification for the target user
        await targetUserRef.collection('notifications').add({
          'type': 'friend_request',
          'message': 'You have a new friend request.',
          'userId': user.imageUrl, // Assuming this is the image URL
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print("Error sending request: $e");
    }
  }

  @override
  Future<void> unfollowUser(UserEntity user) async {
    final userCollection = firebaseFirestore.collection(FirebaseConst.users);
    final currentUid = await getCurrentUid();

    final targetUserRef = userCollection.doc(user.uid);
    final currentUserRef = userCollection.doc(currentUid);

    try {
      // Add current user's UID to target user's "followers" array and decrement followerCount
      await targetUserRef.update({
        'followers': FieldValue.arrayRemove([currentUid]),
        'followerCount': FieldValue.increment(-1),
      });

      // Ensure followerCount is not negative
      final targetUserDoc = await targetUserRef.get();
      final targetFollowerCount = targetUserDoc.data()!['followerCount'] ?? 0;
      if (targetFollowerCount < 0) {
        await targetUserRef.update({'followerCount': 0});
      }

      // Add target user's UID to current user's "following" array and decrement followingCount
      await currentUserRef.update({
        'following': FieldValue.arrayRemove([user.uid]),
        'followingCount': FieldValue.increment(-1),
      });

      // Ensure followingCount is not negative
      final currentUserDoc = await currentUserRef.get();
      final currentFollowingCount =
          currentUserDoc.data()!['followingCount'] ?? 0;
      if (currentFollowingCount < 0) {
        await currentUserRef.update({'followingCount': 0});
      }
    } catch (e) {
      print("Error unfollowing user: $e");
    }
  }

  @override
  Future<void> rejectRequest(UserEntity user) async {
    final userCollection = firebaseFirestore.collection(FirebaseConst.users);
    final currentUid = await getCurrentUid();

    final targetUserRef = userCollection.doc(currentUid);

    try {
      final targetUserDoc = await targetUserRef.get();

      if (targetUserDoc.exists) {
        // Retrieve current requests or initialize an empty list
        List requests = targetUserDoc.data()?['requests'] ?? [];

        // Remove the requested user's UID from requests list
        requests.remove(user.uid);

        // Update the document with the updated requests list
        await targetUserRef.update({'requests': requests});
      }
    } catch (e) {
      print("Error rejecting request: $e");
    }
  }

  @override
  Future<void> createMessageWithId(ChatEntity message) async {
    final uid = await getCurrentUid();

    final chatCollection = firebaseFirestore.collection(FirebaseConst.messages);
    final userCollection = firebaseFirestore.collection(FirebaseConst.users);

    final newMessage = ChatModel(
      messageId: message.messageId,
      members: message.members,
      lastMessage: message.lastMessage,
      isRead: message.isRead,
    ).toJson();

    try {
      final messageExists = await isMessageIdExists(message.messageId!);

      if (!messageExists) {
        await chatCollection.doc(message.messageId).set(newMessage);

        final userRef = await userCollection.doc(uid).get();
        if (!userRef.exists) {
          await userCollection.doc(uid).set({
            "messages": FieldValue.arrayUnion([message.messageId]),
          });
        } else {
          await userCollection.doc(uid).update({
            "messages": FieldValue.arrayUnion([message.messageId]),
          });
        }
      } else {
        await chatCollection.doc(message.messageId).update(newMessage);

        final userRef = await userCollection.doc(uid).get();
        if (!userRef.exists) {
          await userCollection.doc(uid).set({
            "messages": FieldValue.arrayUnion([message.messageId]),
          });
        } else {
          await userCollection.doc(uid).update({
            "messages": FieldValue.arrayUnion([message.messageId]),
          });
        }
      }
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  @override
  Stream<List<MessageEntity>> fetchMessages(String messageId) {
    final chatCollection = FirebaseFirestore.instance
        .collection(FirebaseConst.messages)
        .doc(messageId)
        .collection(FirebaseConst.messages)
        .orderBy("createAt", descending: false); // Check field name

    return chatCollection.snapshots().map((querySnapshot) {
      print(
          "Received ${querySnapshot.docs.length} messages from Firestore"); // Debug print
      return querySnapshot.docs.map((doc) {
        print("Document data: ${doc.data()}"); // Debug print each document
        return MessageModel.fromSnapshot(doc);
      }).toList();
    });
  }

  @override
  Future<void> sendMessage(String messageId, String message) async {
    final uid = await getCurrentUid();
    final userDoc = firebaseFirestore
        .collection(FirebaseConst.messages)
        .doc(messageId)
        .collection(FirebaseConst.messages);

    final msgDoc = firebaseFirestore.collection(FirebaseConst.messages);

    // Create the message data structure
    final messageData = MessageModel(
      message: message,
      senderId: uid,
      createAt: Timestamp.now(),
    ).toJson();

    final mid = const Uuid().v4();

    try {
      final chatRef = await userDoc.doc(messageId).get();

      if (!chatRef.exists) {
        userDoc.doc(mid).set(messageData);
        msgDoc.doc(messageId).update({
          "lastMessage": message,
          "isRead": false,
        });
      } else {
        userDoc.doc(mid).update(messageData);
      }
    } catch (e) {
      print('Error sending message: $e');
      // Handle error, maybe rethrow or handle it within the UI
    }
  }

  @override
  Stream<List<ChatEntity>> fetchConversations() {
    final chatCollection = firebaseFirestore.collection(FirebaseConst.messages);

    return chatCollection.snapshots().map((querySnapshot) {
      print(
          "Received ${querySnapshot.docs.length} messages from Firestore"); // Debug print
      return querySnapshot.docs.map((doc) {
        print("Document data: ${doc.data()}"); // Debug print each document
        return ChatModel.fromJson(doc);
      }).toList();
    });
  }

  @override
  Future<bool> isMessageIdExists(String messageId) async {
    try {
      final doc = await firebaseFirestore
          .collection(FirebaseConst.messages)
          .doc(messageId)
          .get();

      return doc.exists;
    } catch (_) {
      return false;
    }
  }
}
