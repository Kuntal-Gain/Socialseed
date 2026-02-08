import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Notification types
enum NotificationType {
  like,
  comment,
  friendRequest,
  follow,
  mention,
  post,
}

// Mock model - replace with your actual model
class NotificationItem {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final NotificationType type;
  final String message;
  final DateTime timestamp;
  final String? postId;
  final String? postImage;
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.type,
    required this.message,
    required this.timestamp,
    this.postId,
    this.postImage,
    this.isRead = false,
  });
}

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  // Mock data - replace with your actual provider
  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: '1',
      userId: 'user1',
      userName: 'Akane Tachibana',
      userAvatar:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
      type: NotificationType.like,
      message: 'Liked Your Latest Post , Tap to View Post',
      timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    NotificationItem(
      id: '2',
      userId: 'user2',
      userName: 'Akane Tachibana',
      userAvatar:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
      type: NotificationType.comment,
      message: 'Commented Your Latest Post "Nice Pic"',
      timestamp: DateTime.now().subtract(const Duration(seconds: 30)),
    ),
    NotificationItem(
      id: '3',
      userId: 'user3',
      userName: 'Akane Tachibana',
      userAvatar:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
      type: NotificationType.like,
      message: 'Liked Your Latest Post , Tap to View Post',
      timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    NotificationItem(
      id: '4',
      userId: 'user4',
      userName: 'Akane Tachibana',
      userAvatar:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
      type: NotificationType.comment,
      message: 'Commented Your Latest Post "Nice Pic"',
      timestamp: DateTime.now().subtract(const Duration(seconds: 30)),
    ),
    NotificationItem(
      id: '5',
      userId: 'user5',
      userName: 'Manjiro Sano',
      userAvatar:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
      type: NotificationType.friendRequest,
      message: 'Sent you a friend request',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    NotificationItem(
      id: '6',
      userId: 'user6',
      userName: 'Emily Davis',
      userAvatar:
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150',
      type: NotificationType.follow,
      message: 'Started following you',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    NotificationItem(
      id: '7',
      userId: 'user7',
      userName: 'Alex Martinez',
      userAvatar:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
      type: NotificationType.mention,
      message: 'Mentioned you in a comment',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
    NotificationItem(
      id: '8',
      userId: 'user8',
      userName: 'Jessica Taylor',
      userAvatar:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      type: NotificationType.post,
      message: 'Posted a new photo',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      postImage:
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=150',
    ),
  ];

  void _handleNotificationTap(NotificationItem notification) {
    // Handle notification tap based on type
    switch (notification.type) {
      case NotificationType.like:
      case NotificationType.comment:
      case NotificationType.post:
        // Navigate to post detail
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Opening post...'),
            duration: Duration(seconds: 1),
          ),
        );
        break;
      case NotificationType.friendRequest:
        // Navigate to friend requests
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Opening friend requests...'),
            duration: Duration(seconds: 1),
          ),
        );
        break;
      case NotificationType.follow:
      case NotificationType.mention:
        // Navigate to profile
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening ${notification.userName}\'s profile...'),
            duration: const Duration(seconds: 1),
          ),
        );
        break;
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return 'Yesterday';
      }
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min';
    } else {
      return 'Just Now';
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.like:
        return Icons.favorite;
      case NotificationType.comment:
        return Icons.chat_bubble;
      case NotificationType.friendRequest:
        return Icons.person_add;
      case NotificationType.follow:
        return Icons.person_add;
      case NotificationType.mention:
        return Icons.alternate_email;
      case NotificationType.post:
        return Icons.photo;
    }
  }

  Color _getNotificationIconColor(NotificationType type) {
    switch (type) {
      case NotificationType.like:
        return const Color(0xffFF3131);
      case NotificationType.comment:
        return Colors.blue;
      case NotificationType.friendRequest:
        return Colors.green;
      case NotificationType.follow:
        return Colors.purple;
      case NotificationType.mention:
        return Colors.orange;
      case NotificationType.post:
        return Colors.pink;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _notifications.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return _buildNotificationCard(notification);
              },
            ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    return GestureDetector(
      onTap: () => _handleNotificationTap(notification),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar with notification icon badge
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: NetworkImage(notification.userAvatar),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: _getNotificationIconColor(notification.type),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      _getNotificationIcon(notification.type),
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 12),

            // Notification content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Username
                  Text(
                    notification.userName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Message
                  Text(
                    notification.message,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Time and optional post thumbnail
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Time
                Text(
                  _getTimeAgo(notification.timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),

                // Post thumbnail if available
                if (notification.postImage != null) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      notification.postImage!,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xffFF3131).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none,
                size: 64,
                color: const Color(0xffFF3131).withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Notifications',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'You\'re all caught up! Check back later for new notifications.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
