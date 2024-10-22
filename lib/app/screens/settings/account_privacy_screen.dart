import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:socialseed/utils/constants/firebase_const.dart';

import '../../../utils/constants/color_const.dart';

class PrivacySettingsScreen extends StatefulWidget {
  final String userId;
  const PrivacySettingsScreen({Key? key, required this.userId})
      : super(key: key);

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool isPrivateAccount = false;

  @override
  void initState() {
    super.initState();
    fetchPrivacySetting();
  }

  Future<void> fetchPrivacySetting() async {
    try {
      final userDoc = FirebaseFirestore.instance
          .collection(FirebaseConst.users)
          .doc(widget.userId);
      final snapshot = await userDoc.get();

      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null && data.containsKey('isPrivate')) {
          setState(() {
            isPrivateAccount = data['isPrivate'] as bool;
          });
        } else {
          // If 'isPrivate' field doesn't exist, set it to false and update Firestore
          await userDoc.update({'isPrivate': false});
          setState(() {
            isPrivateAccount = false;
          });
          debugPrint("'isPrivate' field created and set to false.");
        }
      } else {
        debugPrint('User document does not exist.');
      }
    } catch (e) {
      debugPrint('Error fetching privacy setting: $e');
    }
  }

  Future<void> updatePrivacySetting(bool isPrivate) async {
    final userDoc = FirebaseFirestore.instance
        .collection(FirebaseConst.users)
        .doc(widget.userId);
    try {
      await userDoc.update({'isPrivate': isPrivate});
    } catch (e) {
      debugPrint('Error updating privacy setting: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: AppBar(
        title: const Text('Privacy Settings'),
        backgroundColor: AppColor.whiteColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ListTile(
              title: const Text('Private Account'),
              subtitle:
                  const Text('Only people you approve can see your posts'),
              trailing: Switch(
                value: isPrivateAccount,
                onChanged: (value) {
                  setState(() {
                    isPrivateAccount = value;
                  });
                  updatePrivacySetting(value);
                },
              ),
            ),
            const Divider(),
            const ListTile(
              title: Text('Two-Factor Authentication'),
              subtitle: Text('Implemented Later'),
              trailing: Icon(Icons.lock_outline),
            ),
            const Divider(),
            const ListTile(
              title: Text('Blocked Accounts'),
              subtitle: Text('Implemented Later'),
              trailing: Icon(Icons.person_add_disabled),
            ),
          ],
        ),
      ),
    );
  }
}
