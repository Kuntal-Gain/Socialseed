import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:socialseed/app/widgets/notification_widget.dart';
import 'package:socialseed/utils/constants/firebase_const.dart';

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
      if (notification['type'] == 'follow' ||
          notification['type'] == 'friend_request') {
        final userId = notification[
            'userId']; // Assuming `userId` is part of the notification data

        return userId;
      } else if (notification['type'] == 'like' ||
          notification['type'] == 'comment') {
        final postId = notification[
            'postId']; // Assuming `postId` is part of the notification data
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text('My Notifications'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.uid)
            .collection('notifications')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching notifications'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No notifications'));
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
