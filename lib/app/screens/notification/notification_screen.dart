import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:socialseed/utils/custom/shimmer_effect.dart';

import '../../../utils/constants/color_const.dart';
import '../../../utils/constants/firebase_const.dart';
import '../../../utils/constants/text_const.dart';
import '../../widgets/notification_widget.dart';

class NotificationScreen extends StatefulWidget {
  final String uid;
  const NotificationScreen({super.key, required this.uid});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
  }

  Future<String?> fetchImageFromNotification(
      Map<String, dynamic> notification) async {
    try {
      await Future.delayed(const Duration(milliseconds: 200)); // Added delay

      if (notification['type'] == 'follow' ||
          notification['type'] == 'friend_request') {
        final userId = notification['userId'];
        return userId;
      } else if (notification['type'] == 'like' ||
          notification['type'] == 'comment') {
        final postId = notification['postId'];
        final postDoc = await FirebaseFirestore.instance
            .collection(FirebaseConst.posts)
            .doc(postId)
            .get();
        if (postDoc.exists) {
          final List<dynamic> imageUrls =
              postDoc.get('images') as List<dynamic>;
          if (imageUrls.isNotEmpty) {
            return imageUrls[0] as String?;
          }
        } else {
          debugPrint('Post does not exist');
        }
      }
      return null;
    } catch (e) {
      debugPrint("Error fetching image: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColor.whiteColor,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text('My Notifications'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.uid)
            .collection('notifications')
            .orderBy('createdAt', descending: true)
            .snapshots()
            .asyncMap((event) async {
          await Future.delayed(const Duration(seconds: 2));
          return event;
        }),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) => shimmerEffectNotification(),
            );
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching notifications'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Column(
              children: [
                Image.network(
                    'https://cdn.dribbble.com/users/1319343/screenshots/6238304/_01-no-notifications.gif'),
                Text(
                  'No Notifications',
                  style: TextConst.headingStyle(20, AppColor.redColor),
                )
              ],
            );
          }

          final notifications = snapshot.data!.docs;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification =
                  notifications[index].data() as Map<String, dynamic>;

              return FutureBuilder<String?>(
                future: fetchImageFromNotification(notification),
                builder: (context, imageSnapshot) {
                  if (!imageSnapshot.hasData || imageSnapshot.data == null) {
                    // Skip this notification if postId doesn't exist
                    return const SizedBox.shrink();
                  }

                  final imageUrl = imageSnapshot.data;
                  final type = notification['type'] ?? '';
                  final message = notification['message'] ?? 'No message';
                  final time = notification['createdAt'] != null
                      ? (notification['createdAt'] as Timestamp)
                      : Timestamp.now();

                  return notificationCard(imageUrl, message, time, type);
                },
              );
            },
          );
        },
      ),
    );
  }
}
