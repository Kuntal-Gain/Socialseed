import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:socialseed/core/usecases/usecases_impl.dart';
import 'package:socialseed/features/story/data/story_usecase.dart';
import 'package:socialseed/features/story/model/story_model.dart';

class StoryUsecaseImpl implements StoryUsecase {
  final firestore = FirebaseFirestore.instance;
  final rtdb = FirebaseDatabase.instance.ref();

  @override
  Future<void> createStory(StoryAsset asset) async {
    final todayId = _todayDocId();
    final Timestamp? now = Timestamp.now();
    final userId = await getCurrentUid();

    final docRef = firestore
        .collection('users')
        .doc(userId)
        .collection('stories')
        .doc(todayId);

    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      // Create new story
      final newStory = StoryModel(
        storyId: todayId,
        creatorUid: userId,
        createdAt: now,
        updatedAt: now,
        date: Timestamp.fromDate(DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
        )),
        assets: [asset],
        viewers: [],
      );

      await docRef.set(newStory.toMap());
    } else {
      // Append new asset
      await docRef.update({
        "assets": FieldValue.arrayUnion([asset.toMap()]),
        "updatedAt": now,
      });
    }
  }

  @override
  Future<List<StoryModel>> getFriendStories(List<String> friendUids) async {
    final todayId = _todayDocId();
    final List<StoryModel> stories = [];

    final futures = friendUids.map((uid) {
      return firestore
          .collection('users')
          .doc(uid)
          .collection('stories')
          .doc(todayId)
          .get();
    }).toList();

    final docs = await Future.wait(futures);

    for (final doc in docs) {
      if (doc.exists) {
        stories.add(StoryModel.fromMap(doc.data()!, doc.id));
      }
    }

    return stories;
  }

  @override
  Future<StoryModel> getUserStories(String userId) async {
    final todayId = _todayDocId();

    final doc = await firestore
        .collection('users')
        .doc(userId)
        .collection('stories')
        .doc(todayId)
        .get();

    if (!doc.exists) {
      throw Exception("No story found for today");
    }

    return StoryModel.fromMap(doc.data()!, doc.id);
  }

  @override
  Future<StoryModel> viewStory(String userId) async {
    final currentUid = await getCurrentUid(); // replace properly
    final todayId = _todayDocId();

    final docRef = firestore
        .collection('users')
        .doc(userId)
        .collection('stories')
        .doc(todayId);

    await docRef.update({
      "viewers": FieldValue.arrayUnion([currentUid])
    });

    final updatedDoc = await docRef.get();
    return StoryModel.fromMap(updatedDoc.data()!, updatedDoc.id);
  }

  String _todayDocId() {
    final now = DateTime.now().toUtc();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }
}
