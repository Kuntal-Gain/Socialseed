import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:socialseed/core/network/api_endpoint.dart';
import 'package:socialseed/core/network/locator.dart';
import 'package:socialseed/features/auth_module/data/cred/creds_usecase.dart';
import 'package:socialseed/features/auth_module/model/user_model.dart';
import 'package:socialseed/features/friends_module/data/friend_usecases.dart';
import 'package:socialseed/features/friends_module/model/request_model.dart';

import '../../../core/usecases/usecases_impl.dart';

class FriendUsecaseImpl extends FriendUsecases {
  final _firestore = FirebaseFirestore.instance;
  final dbRef = FirebaseDatabase.instance.ref();
  final credUsecase = getIt<CredsUseCase>();

  @override
  Future<void> acceptReq({required String reciverUid}) async {
    final currentUid = await getCurrentUid(); // YOU

    // 1️⃣ RTDB: Remove request from YOUR inbox
    final rtdb = dbRef.child('requests/$currentUid');

    final snap = await rtdb.get();
    if (!snap.exists || snap.value == null) return;

    final data = Map<String, dynamic>.from(snap.value as Map);

    final List<Map<String, dynamic>> list = (data['requests'] as List? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    // 🔥 Remove the other user from YOUR requests
    list.removeWhere((e) => e['uid'] == reciverUid);

    await rtdb.set({
      'requests': list,
      'count': list.length,
    });

    // 2️⃣ Firestore: Update followers/following

    final currentUserRef =
        _firestore.collection(Collections.users).doc(currentUid);
    final otherUserRef =
        _firestore.collection(Collections.users).doc(reciverUid);

    await _firestore.runTransaction((tx) async {
      final currentSnap = await tx.get(currentUserRef);
      final otherSnap = await tx.get(otherUserRef);

      final currentFollowers =
          List<String>.from(currentSnap.data()?['followers'] ?? []);
      final otherFollowing =
          List<String>.from(otherSnap.data()?['following'] ?? []);

      // They become your follower
      if (!currentFollowers.contains(reciverUid)) {
        currentFollowers.add(reciverUid);
      }

      // You become their following
      if (!otherFollowing.contains(currentUid)) {
        otherFollowing.add(currentUid);
      }

      tx.update(currentUserRef, {'followers': currentFollowers});
      tx.update(otherUserRef, {'following': otherFollowing});
    });
  }

  @override
  Stream<RequestListModel> getRequests() {
    return getCurrentUid().asStream().asyncExpand((currentUid) {
      return dbRef.child('requests/$currentUid').onValue.map((event) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;

        if (data == null) {
          return const RequestListModel(requests: [], count: 0);
        }

        return RequestListModel.fromJson(
          Map<String, dynamic>.from(data),
        );
      });
    });
  }

  @override
  Future<List<User>> getSuggestions() async {
    final snapshot = await _firestore.collection(Collections.users).get();

    final currentUser = await credUsecase.getCurrentUser();

    final allUsers =
        snapshot.docs.map((doc) => User.fromJson(doc.data())).toList();

    final followingSet = currentUser?.following?.toSet() ?? {};

    final suggestions = allUsers.where((user) {
      // ❌ Don't suggest yourself
      if (user.uid == currentUser?.uid) return false;

      // ❌ Don't suggest users already followed
      if (followingSet.contains(user.uid)) return false;

      return true;
    }).toList();

    return suggestions;
  }

  @override
  Future<void> sendRequest(RequestModel request, String toUid) async {
    final ref = FirebaseDatabase.instance.ref('requests/$toUid');

    final snap = await ref.get();

    List<dynamic> list = [];
    int count = 0;

    if (snap.exists && snap.value != null) {
      final data = Map<String, dynamic>.from(snap.value as Map);

      if (data['requests'] != null) {
        list = List.from(data['requests'] as List);
        count = data['count'] ?? list.length;
      }
    }

    // 🚫 prevent duplicate from same sender
    final exists = list.any((e) => e['uid'] == request.uid);
    if (exists) return;

    list.add(request.toJson());
    count = list.length;

    await ref.set({
      'requests': list,
      'count': count,
    });
  }

  @override
  Future<void> rejectOrCancelReq({required String reciverUid}) async {
    final currentUid = await getCurrentUid(); // logged-in user
    final rtdb = dbRef.child('requests/$reciverUid');

    final snap = await rtdb.get();
    if (!snap.exists || snap.value == null) return;

    final data = Map<String, dynamic>.from(snap.value as Map);

    final List<Map<String, dynamic>> list = (data['requests'] as List? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    // 🔥 Remove the current user from the receiver's request list
    list.removeWhere((e) => e['uid'] == currentUid);

    await rtdb.set({
      'requests': list,
      'count': list.length,
    });
  }

  @override
  Future<bool> isSentRequest({required String receiverUid}) async {
    final currentUid = await getCurrentUid();

    final ref = dbRef.child('requests/$receiverUid/requests');

    final snap = await ref.get();

    if (!snap.exists || snap.value == null) return false;

    final list = (snap.value as List)
        .where((e) => e != null)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    final exists = list.any((e) => e['uid'] == currentUid);

    return exists;
  }
}
