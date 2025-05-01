import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialseed/features/services/theme_service.dart';
import 'package:socialseed/utils/constants/firebase_const.dart';

import '../../../utils/constants/color_const.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';

import '../../../utils/constants/text_const.dart';

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
    final bg = Provider.of<ThemeService>(context).isDarkMode
        ? AppColor.bgDark
        : AppColor.whiteColor;

    final textColor = Provider.of<ThemeService>(context).isDarkMode
        ? AppColor.whiteColor
        : AppColor.blackColor;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Privacy Settings'),
        backgroundColor: bg,
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(
              'Private Account',
              style: TextConst.headingStyle(
                16,
                textColor,
              ),
            ),
            subtitle: Text(
              'Only people you approve can see your posts',
              style: TextConst.MediumStyle(
                14,
                textColor,
              ),
            ),
            trailing: CustomAnimatedToggleSwitch<bool>(
              current: isPrivateAccount,
              values: const [false, true],
              iconBuilder: (context, value, size) => Icon(
                isPrivateAccount ? Icons.lock_outline : Icons.lock_open,
                size: 20,
                color: !isPrivateAccount ? Colors.green : Colors.red,
              ),
              wrapperBuilder: (context, size, child) => Container(
                width: 80,
                height: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: !isPrivateAccount
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                ),
                child: child,
              ),
              foregroundIndicatorBuilder: (context, size) => Padding(
                padding: const EdgeInsets.all(4),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColor.whiteColor,
                    border: Border.all(
                      color: !isPrivateAccount ? Colors.green : Colors.red,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  isPrivateAccount = value;
                });
                updatePrivacySetting(value);
              },
            ),
          ),
          ListTile(
            title: const Text('Two-Factor Authentication'),
            subtitle: const Text('Implemented Later'),
            trailing: const Icon(Icons.lock_outline),
            onTap: () {},
          ),
          const ListTile(
            title: Text('Blocked Accounts'),
            subtitle: Text('Implemented Later'),
            trailing: Icon(Icons.person_add_disabled),
          ),
        ],
      ),
    );
  }
}
