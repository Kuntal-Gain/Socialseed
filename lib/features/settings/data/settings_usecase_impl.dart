import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:socialseed/features/settings/data/settings_usecase.dart';
import 'package:socialseed/features/settings/model/milestones_model.dart';

class SettingsUsecaseImpl implements SettingsUsecase {
  final _firestore = FirebaseFirestore.instance;
  final rtdb = FirebaseDatabase.instance.ref();

  CollectionReference get _milestonesRef =>
      _firestore.collection('milestones_data');

  @override
  Future<void> createMilestone(MilestoneModel milestone) async {
    try {
      final docRef = _milestonesRef.doc(); // 🔥 Firestore generates ID

      final payload = milestone.toJson();

      await docRef.set(payload);
    } catch (e, st) {
      debugPrint('milestone error: $e\n$st');
      rethrow;
    }
  }

  @override
  Future<List<MilestoneModel>> getMilestones() async {
    try {
      final snap = await _milestonesRef.get();

      return snap.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return MilestoneModel.fromJson(data);
      }).toList();
    } catch (e, st) {
      debugPrint('milestones error: $e\n$st');
      rethrow;
    }
  }
}
