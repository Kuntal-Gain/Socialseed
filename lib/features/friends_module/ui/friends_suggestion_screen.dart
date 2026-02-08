import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socialseed/core/services/route_generator.dart';
import 'package:socialseed/core/utils/constants/color_const.dart';
import 'package:socialseed/core/utils/helpers/app_loader.dart';
import 'package:socialseed/core/utils/helpers/failure_widget.dart';
import 'package:socialseed/core/utils/helpers/no_data_found_widget.dart';
import 'package:socialseed/core/utils/helpers/screen_utils.dart';
import 'package:socialseed/core/utils/helpers/scroll_view.dart';
import 'package:socialseed/features/auth_module/model/user_model.dart';
import 'package:socialseed/features/auth_module/ui/provider/creds_provider.dart';
import 'package:socialseed/features/friends_module/model/request_model.dart';
import 'package:socialseed/features/friends_module/ui/providers/friend_module_provider.dart';

class FriendRequestsScreen extends ConsumerStatefulWidget {
  const FriendRequestsScreen({super.key});

  @override
  ConsumerState<FriendRequestsScreen> createState() =>
      _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends ConsumerState<FriendRequestsScreen> {
  // Mock data - replace with your actual providers

  bool isLoading = false;

  void _acceptRequest(RequestModel request) async {
    // Show small loading card
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.1),
      builder: (_) {
        return Center(
          child: SizedBox(
            width: 90,
            height: 90, // 👈 square
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: AppLoader().stateLoader(),
              ),
            ),
          ),
        );
      },
    );

    await ref.watch(friendRequestsProvider.notifier).accept(request.uid);

    // Close loading
    if (mounted) Navigator.pop(context);

    // Remove from list
    // setState(() {
    //   _friendRequests.removeWhere((r) => r.id == request.id);
    // });

    // Show success
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You are now friends with ${request.fullName}'),
          backgroundColor: const Color(0xffFF3131),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  void _rejectRequest(RequestModel request) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 800));

    // Close loading
    if (mounted) Navigator.pop(context);

    // Remove from list
    // setState(() {
    //   _friendRequests.removeWhere((r) => r.id == request.id);
    // });

    // Show feedback
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Friend request rejected'),
          backgroundColor: Colors.grey.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  void _sendFriendRequest(User suggestion) async {
    final user = ref.read(currentUserProvider);

    setState(() => isLoading = true);

    final request =
        RequestModel(uid: user?.uid ?? '', fullName: user?.fullName ?? '');

    // ⚡ Await the backend operation
    await ref
        .read(friendRequestsProvider.notifier)
        .send(request, suggestion.uid ?? '');

    setState(() => isLoading = false);

    // Refresh provider AFTER backend updates
    ref.invalidate(hasISentRequestToProvider(suggestion.uid!));

    // Show feedback
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Friend request sent to ${suggestion.fullName}'),
          backgroundColor: const Color(0xffFF3131),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  void _cancelFriendRequest(User suggestion) async {
    // ⚡ Await the backend operation

    setState(() => isLoading = true);

    await ref
        .read(friendRequestsProvider.notifier)
        .cancel(suggestion.uid ?? '');

    setState(() => isLoading = false);

    // Refresh provider AFTER backend updates
    ref.invalidate(hasISentRequestToProvider(suggestion.uid!));

    // Show feedback
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Friend request cancelled'),
          backgroundColor: Colors.grey.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  String getTimeAgo(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final difference = DateTime.now().difference(date);

    if (difference.inDays >= 365) {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    } else if (difference.inDays >= 30) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final reqAsync = ref.watch(friendRequestsProvider);
    final suggAsync = ref.watch(suggestedUsersProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Friend Requests',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            sizeHor(10),
            reqAsync.maybeWhen(
                data: (data) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: const BoxDecoration(
                        color: Color(0xffFF3131),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${data.count}',
                        style: TextStyle(
                          color: AppColor.whiteColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                orElse: () => SizedBox.shrink()),
            const SizedBox(width: 8),
          ],
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(friendRequestsProvider);
          ref.invalidate(suggestedUsersProvider);
          ref.invalidate(hasISentRequestToProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Friend Requests Section
              // if (_friendRequests.isNotEmpty) ...[
              //   ListView.builder(
              //     shrinkWrap: true,
              //     physics: const NeverScrollableScrollPhysics(),
              //     padding:
              //         const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              //     itemCount: _friendRequests.length,
              //     itemBuilder: (context, index) {
              //       final request = _friendRequests[index];
              //       return _buildRequestCard(request);
              //     },
              //   ),
              // ],

              reqAsync.when(
                data: (data) {
                  if (data.count == 0) {
                    return NoDataFoundWidget(
                      icon: Icons.people,
                      title: 'No Requests found',
                      message: 'Try checking back later for new connections',
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: data.count,
                    itemBuilder: (context, index) {
                      final request = data.requests[index];
                      return _buildRequestCard(request);
                    },
                  );
                },
                error: (err, st) => errorWidget(err, st,
                    onRefresh: () => ref.invalidate(friendRequestsProvider)),
                loading: () => AppLoader().stateLoader(),
              ),

              // Suggestions Section

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Text(
                  'You May know them',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),

              suggAsync.when(
                data: (data) {
                  if (data.isEmpty) {
                    return NoDataFoundWidget(
                      icon: Icons.people,
                      title: 'No suggestions found',
                      message: 'Try checking back later for new connections',
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final suggestion = data[index];
                      return _buildSuggestionCard(suggestion);
                    },
                  );
                },
                error: (err, st) => errorWidget(err, st),
                loading: () => AppLoader().stateLoader(),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCard(RequestModel request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: NetworkImage(request.avatarUrl ?? ""),
          ),
          const SizedBox(width: 12),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.fullName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  getTimeAgo(request.createdAt ?? 0),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),

          // Action Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () => _acceptRequest(request),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffFF3131),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                  minimumSize: const Size(70, 36),
                ),
                child: const Text(
                  'Accept',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => _rejectRequest(request),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: const Size(70, 36),
                ),
                child: const Text(
                  'Reject',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(User user) {
    final sendAsync = ref.watch(hasISentRequestToProvider(user.uid ?? ''));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: NetworkImage(user?.avatar ?? ""),
          ),
          const SizedBox(width: 12),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName ?? "",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
              ],
            ),
          ),

          // Action Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              sendAsync.maybeWhen(
                orElse: () => const SizedBox.shrink(),
                data: (isSent) => GestureDetector(
                    onTap: () async {
                      if (isSent) {
                        _cancelFriendRequest(user);
                      } else {
                        _sendFriendRequest(user);
                      }

                      // Only after backend is updated, refresh the provider
                      ref.invalidate(hasISentRequestToProvider(user.uid!));
                    },
                    child: Container(
                      height: 35,
                      width: 130,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color:
                            isSent ? Colors.grey.shade200 : AppColor.redColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: isLoading
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2, // keeps it slim and circular
                                ),
                              )
                            : Text(
                                isSent ? 'Cancel Request' : 'Send Request',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isSent
                                      ? Colors.grey.shade700
                                      : Colors.white,
                                ),
                              ),
                      ),
                    )),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {
                  // Remove suggestion
                  Navigator.pushNamed(context, RouteGenerator.kProfile,
                      arguments: {'uid': user.uid});
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: const Size(70, 36),
                ),
                child: const Text(
                  'View',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
