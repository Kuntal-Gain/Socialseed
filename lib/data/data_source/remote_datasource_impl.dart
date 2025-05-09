// ignore_for_file: avoid_print, curly_braces_in_flow_control_structures, unrelated_type_equality_checks, use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:socialseed/data/data_source/remote_datasource.dart';
import 'package:socialseed/data/models/chat_model.dart';
import 'package:socialseed/data/models/comment_model.dart';

import 'package:socialseed/data/models/post_model.dart';
import 'package:socialseed/data/models/story_model.dart';
import 'package:socialseed/data/models/user_model.dart';
import 'package:socialseed/domain/entities/chat_entity.dart';
import 'package:socialseed/domain/entities/comment_entity.dart';
import 'package:socialseed/domain/entities/message_entity.dart';
import 'package:socialseed/domain/entities/post_entity.dart';
import 'package:socialseed/domain/entities/story_entity.dart';
import 'package:socialseed/domain/entities/user_entity.dart';
import 'package:socialseed/utils/constants/firebase_const.dart';
import 'package:uuid/uuid.dart';

import '../models/message_model.dart';

class RemoteDataSourceImpl implements RemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;
  final FirebaseDatabase firebaseDatabase;

  RemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firebaseFirestore,
    required this.firebaseDatabase,
  });

  @override
  Future<void> createUser(UserEntity user) async {
    final userCollection = firebaseFirestore.collection(FirebaseConst.users);

    final uid = await getCurrentUid();

    userCollection.doc(uid).get().then((newDoc) {
      final newUser = UserModel(
        uid: uid,
        username: user.username.toString(),
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
        archivedContent: const [],
        savedContent: const [],
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
  Future<void> signInUser(UserEntity user) async {
    try {
      if (user.email!.isNotEmpty || user.password!.isNotEmpty) {
        await firebaseAuth.signInWithEmailAndPassword(
          email: user.email!,
          password: user.password!,
        );

        final uid = await getCurrentUid();
        await updateUserStatus(uid, true); // Set online status
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print(e.code);
      } else if (e.code == 'wrong-password') {
        print(e.code);
      }
    }
  }

  @override
  Future<void> updateUserStatus(String uid, bool isOnline) async {
    try {
      print("Attempting to update status for user: $uid, isOnline: $isOnline");

      // Reference the user's document
      final docRef = firebaseFirestore.collection(FirebaseConst.users).doc(uid);

      // Check if the user document exists before updating
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        // Update the active_status field in the Firestore document
        await docRef.update({
          "active_status": isOnline,
          "last_seen": Timestamp.now(),
        });
        print("User status updated successfully for uid: $uid");
      } else {
        print("User document not found for uid: $uid");
      }
    } catch (e) {
      // Log any errors that occur during the update process
      print("Failed to update user status for uid: $uid. Error: $e");
    }
  }

  @override
  Future<void> signOut() async {
    final user = firebaseAuth.currentUser;
    if (user != null) {
      await updateUserStatus(user.uid, false); // Set offline status
      await firebaseAuth.signOut();
    }
  }

  @override
  Future<void> signUpUser(UserEntity user) async {
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
          print("Account Creation Successful");
        });

        return;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        print(e.code);
      } else {
        print('Something went wrong');
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

    if (user.bio != "" && user.bio != null) userInformation['bio'] = user.bio;

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
      likes: post.likes ?? [],
      likedUsers: post.likedUsers ?? [],
      comments: post.comments ?? [],
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
    final userCollection = firebaseFirestore.collection(FirebaseConst.users);

    final currentUid = await getCurrentUid();
    final postRef = await postCollection.doc(post.postid).get();

    if (postRef.exists) {
      List likes = postRef.get('likes');
      final totalLikes = postRef.get('totalLikes');
      List likedUsers = postRef.get('likedUsers') ?? [];

      // Fetch the current user's username
      final currentUserDoc = await userCollection.doc(currentUid).get();
      String currentUsername = "";
      if (currentUserDoc.exists) {
        currentUsername = currentUserDoc.get('username');
      }

      if (likes.contains(currentUid)) {
        // If the user has already liked the post, unlike it
        await postCollection.doc(post.postid).update({
          "likes": FieldValue.arrayRemove([currentUid]),
          "totalLikes": totalLikes - 1
        });
      } else {
        // If the user has not liked the post, like it
        await postCollection.doc(post.postid).update({
          "likes": FieldValue.arrayUnion([currentUid]),
          "totalLikes": totalLikes + 1
        });

        // Only send a notification if the current user is not already in likedUsers
        if (!likedUsers.contains(currentUid)) {
          // Add the current UID to likedUsers
          await postCollection.doc(post.postid).update({
            "likedUsers": FieldValue.arrayUnion([currentUid])
          });

          // Send notification
          await userCollection.doc(post.uid).collection('notifications').add({
            "message": "$currentUsername liked your post",
            "createdAt": FieldValue.serverTimestamp(),
            "postId": post.postid,
            "type": "like"
          });
        }
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
            'userId': user.imageUrl, // Assuming this is the image URL
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
    // get current uid
    final uid = await getCurrentUid();

    // references
    final chatCollection = firebaseFirestore.collection(FirebaseConst.messages);
    final userCollection =
        firebaseFirestore.collection(FirebaseConst.users).doc(uid);
    final dbRef = firebaseDatabase.ref();

    // models
    final convo = ChatModel(
      messageId: message.messageId,
      members: message.members,
      lastMessage: message.lastMessage,
      isRead: message.isRead,
      lastMessageSenderId: message.lastMessageSenderId,
      timestamp: message.timestamp,
    ).toJson();

    final messageEntity = MessageModel(
      messageId: null, // will be added after push()
      senderId: uid,
      message: message.lastMessage,
      timestamp: message.timestamp,
      isSeen: false,
    ).toJson();

    try {
      // get the chat reference
      final chatRef = await chatCollection.doc(message.messageId).get();
      if (!chatRef.exists) {
        await chatCollection.doc(message.messageId).set(convo);
        await userCollection.update({
          'messages': FieldValue.arrayUnion([message.messageId])
        });
      } else {
        await chatCollection.doc(message.messageId).update(convo);
      }

      //  get the chat metadata reference
      final chatMetaRef = dbRef.child("chats").child(message.messageId!);
      final metaSnapshot = await chatMetaRef.once();

      if (metaSnapshot.snapshot.value == null) {
        await chatMetaRef.update({
          "participants": message.members,
          "createdAt": message.timestamp,
        });
      }

      // push message inside /chats/{chatId}/messages/
      final newMessageRef = chatMetaRef.child("messages").push();

      final key = newMessageRef.key;

      await newMessageRef.set({...messageEntity, "messageId": key});

      print("Message pushed with key: $key");
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Stream<List<MessageEntity>> fetchMessages(String messageId) {
    final dbRef = firebaseDatabase
        .ref()
        .child("chats")
        .child(messageId)
        .child("messages");

    return dbRef.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data == null) return [];

      final messages = data.entries.map((entry) {
        final msgMap = Map<String, dynamic>.from(entry.value);

        return MessageModel(
          messageId: entry.key,
          message: msgMap['message'],
          senderId: msgMap['senderId'],
          timestamp: msgMap['timestamp'],
          isSeen: msgMap['isSeen'],
        );
      }).toList();

      // Optional: Sort messages by timestamp
      messages.sort((a, b) => (a.timestamp ?? 0).compareTo(b.timestamp ?? 0));

      return messages;
    });
  }

  @override
  Future<void> sendMessage(String messageId, String message) async {
    // current uid
    final uid = await getCurrentUid();

    // references
    final chatCollection =
        firebaseFirestore.collection(FirebaseConst.messages).doc(messageId);

    final dbRef = firebaseDatabase
        .ref()
        .child("chats")
        .child(messageId)
        .child("messages")
        .push();

    final newMessage = MessageModel(
      messageId: null,
      senderId: uid,
      message: message,
      timestamp: Timestamp.now().millisecondsSinceEpoch,
      isSeen: true,
    ).toJson();

    try {
      await dbRef.set(newMessage);

      await chatCollection.update({
        'lastMessage': message,
        'isRead': FieldValue.arrayUnion([uid]),
        'lastMessageSenderId': uid,
        'timestamp': Timestamp.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Stream<List<ChatEntity>> fetchConversations() {
    final chatCollection = firebaseFirestore.collection("chats");

    return chatCollection.snapshots().map((snapshot) {
      try {
        return snapshot.docs.map((doc) {
          final data = doc.data();

          // Defensive check in case any key is missing
          return ChatModel(
            messageId: data['messageId'] ?? '',
            members: List<String>.from(data['members'] ?? []),
            lastMessage: data['lastMessage'] ?? '',
            isRead: List<String>.from(data['isRead'] ?? []),
            lastMessageSenderId: data['lastMessageSenderId'] ?? '',
            timestamp: data['timestamp'] ?? 0,
          );
        }).toList();
      } catch (e) {
        print("Error in fetchConversations(): $e");
        return [];
      }
    });
  }

  @override
  Future<bool> isMessageIdExists(String messageId) async {
    final chatCollection = firebaseFirestore.collection("messages");

    // Try to get the doc with given messageId
    final chatDoc = await chatCollection.doc(messageId).get();

    // Return true if it exists, otherwise false
    return chatDoc.exists;
  }

  @override
  Future<void> addStory(StoryEntity story) async {
    final uid = await getCurrentUid();

    // Reference to the user's document in the users collection
    final userDoc = firebaseFirestore.collection(FirebaseConst.users).doc(uid);

    // Reference to the stories subcollection under the user's document
    final storySubcollection = userDoc.collection(FirebaseConst.story);

    // Reference to the global stories collection
    final globalStoryCollection =
        firebaseFirestore.collection(FirebaseConst.story);

    // Convert the story data to a map
    final storyData = StoryModel(
      id: story.id,
      userId: story.userId,
      storyData: story.storyData,
      createdAt: story.createdAt,
      expiresAt: story.expiresAt,
      viewers: story.viewers,
      content: story.content,
    ).toJson();

    try {
      // Set or update the story document in the user's subcollection
      final userStoryRef = await storySubcollection.doc(story.id).get();
      if (!userStoryRef.exists) {
        await storySubcollection.doc(story.id).set(storyData);
      } else {
        await storySubcollection.doc(story.id).update(storyData);
      }

      // Set or update the story document in the global collection
      final globalStoryRef = await globalStoryCollection.doc(story.id).get();
      if (!globalStoryRef.exists) {
        await globalStoryCollection.doc(story.id).set(storyData);
      } else {
        await globalStoryCollection.doc(story.id).update(storyData);
      }

      // Add the story ID to the "stories" field in the user's document
      await userDoc.update({
        "stories":
            FieldValue.arrayUnion([story.id]) // Append storyId to the array
      });

      print(
          'Story added successfully to both collections and user document updated');
    } catch (e) {
      print('Error adding story: $e');
    }
  }

  @override
  Stream<List<StoryEntity>> fetchStories(String uid) {
    final storyCollection = firebaseFirestore.collection(FirebaseConst.story);

    return storyCollection
        // Remove the where clause to fetch all stories
        .snapshots()
        .map((querySnapshot) {
      final currentTime = DateTime.now();

      return querySnapshot.docs
          .map((e) => StoryModel.fromSnapshot(e))
          .where((story) => story.expiresAt.toDate().isAfter(currentTime))
          .toList();
    });
  }

  @override
  Future<void> viewStory(StoryEntity story) async {
    final uid = await getCurrentUid();

    final storyCollection = firebaseFirestore.collection(FirebaseConst.story);
    final storyRef = await storyCollection.doc(story.id).get();

    if (storyRef.exists) {
      List viewers = storyRef.get('viewers');
      if (!viewers.contains(uid)) {
        await storyCollection.doc(story.id).update({
          "viewers": FieldValue.arrayUnion([uid]),
        });
      }
    }
  }

  @override
  Future<void> archievePost(PostEntity post) async {
    final uid = await getCurrentUid();

    final archieveCollection = firebaseFirestore
        .collection(FirebaseConst.users)
        .doc(uid)
        .collection('archieved');
    final userCollection = firebaseFirestore.collection(FirebaseConst.users);
    final postCollection =
        firebaseFirestore.collection('posts'); // Reference to posts collection

    final data = PostModel(
      postid: post.postid,
      uid: post.uid,
      username: post.username,
      postType: post.postType,
      content: post.content,
      images: post.images,
      likes: post.likes,
      comments: post.comments,
      totalLikes: post.totalLikes,
      totalComments: post.totalComments,
      location: post.location,
      tags: post.tags,
      creationDate: post.creationDate,
      profileId: post.profileId,
      isVerified: post.isVerified,
      home: post.home,
      school: post.school,
      shares: post.shares,
      work: post.work,
      college: post.college,
      likedUsers: post.likedUsers,
    ).toJson();

    try {
      final archievePostRef = await archieveCollection.doc(post.postid).get();
      final userRef = await userCollection.doc(uid).get();

      // Archive post in 'archived' collection
      if (!archievePostRef.exists) {
        await archieveCollection.doc(post.postid).set(data);
      } else {
        await archieveCollection.doc(post.postid).update(data);
      }

      // Check if 'archivedContent' exists, and initialize if it doesn't
      if (userRef.exists) {
        List posts = [];

        if (userRef.data()!.containsKey('archivedContent')) {
          posts = userRef.get('archivedContent');
        } else {
          // Initialize 'archivedContent' as an empty list if it doesn't exist
          await userCollection.doc(uid).set(
              {'archivedContent': []},
              SetOptions(
                  merge: true)); // Merge to avoid overwriting other fields
        }

        if (!posts.contains(post.postid)) {
          await userCollection.doc(uid).update({
            "archivedContent": FieldValue.arrayUnion([post.postid]),
          });
        }
      }

      // Check if post exists before deleting
      final postDoc = await postCollection.doc(post.postid).get();
      if (postDoc.exists) {
        await postCollection.doc(post.postid).delete();
        print('Post deleted successfully');
      } else {
        print('Post does not exist, so it cannot be deleted');
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  @override
  Stream<List<PostEntity>> fetchArchievePosts(String uid) {
    final archieveCollection = firebaseFirestore
        .collection(FirebaseConst.users)
        .doc(uid)
        .collection('archieved');

    return archieveCollection.snapshots().map((querySnapshot) {
      return querySnapshot.docs.map((e) => PostModel.fromSnapShot(e)).toList();
    });
  }

  @override
  Stream<List<PostEntity>> fetchSavedPosts(String uid) {
    final savedCollection = firebaseFirestore
        .collection(FirebaseConst.users)
        .doc(uid)
        .collection('saved-posts');

    return savedCollection.snapshots().map((querySnapshot) {
      return querySnapshot.docs.map((e) => PostModel.fromSnapShot(e)).toList();
    });
  }

  @override
  Future<void> savePost(PostEntity post) async {
    final uid = await getCurrentUid();

    final savedPostColection = firebaseFirestore
        .collection(FirebaseConst.users)
        .doc(uid)
        .collection('saved-posts');
    final userCollection = firebaseFirestore.collection(FirebaseConst.users);

    final data = PostModel(
      postid: post.postid,
      uid: post.uid,
      username: post.username,
      postType: post.postType,
      content: post.content,
      images: post.images,
      likes: post.likes,
      comments: post.comments,
      totalLikes: post.totalLikes,
      totalComments: post.totalComments,
      location: post.location,
      tags: post.tags,
      creationDate: post.creationDate,
      profileId: post.profileId,
      isVerified: post.isVerified,
      home: post.home,
      school: post.school,
      shares: post.shares,
      work: post.work,
      college: post.college,
      likedUsers: post.likedUsers,
    ).toJson();

    try {
      final savedPostRef = await savedPostColection.doc(post.postid).get();
      final userRef = await userCollection.doc(uid).get();

      if (!savedPostRef.exists) {
        savedPostColection.doc(post.postid).set(data);
      } else {
        savedPostColection.doc(post.postid).update(data);
      }

      if (userRef.exists) {
        List posts = userRef.get('savedContent');
        if (!posts.contains(post.postid)) {
          await userCollection.doc(uid).update({
            "savedContent": FieldValue.arrayUnion([post.postid]),
          });
        } else {
          await userCollection.doc(uid).update({
            "savedContent": FieldValue.arrayRemove([post.postid]),
          });
        }
      }
    } catch (_) {
      print('error has occurs');
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      print('Password reset email sent to $email');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        print('The email address is invalid.');
      } else if (e.code == 'user-not-found') {
        print('No user found with this email.');
      } else {
        print('Something went wrong: ${e.message}');
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }
}
