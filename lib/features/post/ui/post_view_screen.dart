import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socialseed/core/utils/helpers/app_loader.dart';
import 'package:socialseed/core/utils/helpers/failure_widget.dart';
import 'package:socialseed/core/utils/helpers/no_data_found_widget.dart';
import 'package:socialseed/core/utils/helpers/scroll_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialseed/features/auth_module/ui/provider/creds_provider.dart';
import 'package:socialseed/features/post/ui/provider/post_provider.dart';

import '../../../core/utils/constants/color_const.dart';
import '../../../core/utils/helpers/appbar.dart';
import '../../feed/ui/widget/post_widget.dart';
import '../model/post_model.dart';

class PostViewScreen extends ConsumerStatefulWidget {
  final PostModel post;
  const PostViewScreen({super.key, required this.post});

  @override
  ConsumerState<PostViewScreen> createState() => _PostViewScreenState();
}

class _PostViewScreenState extends ConsumerState<PostViewScreen> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  final List<Comment> _comments = []; // Replace with your data source
  String? _replyingToCommentId;
  String? _replyingToUsername;
  bool isReply = false;

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final commentAsync =
        ref.watch(postCommentsProvider(widget.post.postId ?? ''));
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: CommonAppbar(title: 'Post'),
      body: CommonScreenWrapper(
        containsScrollable: true,
        body: Column(
          children: [
            // Post content (non-scrollable)
            PostWidget(post: widget.post),

            commentAsync.when(
              data: (comments) {
                return comments.isEmpty
                    ? NoDataFoundWidget(
                        title: 'No comments yet',
                        icon: Icons.chat_bubble_outline_rounded,
                        message:
                            'Be the first to comment on this post. Start the conversation!',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        itemCount: comments.length,
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return _buildCommentItem(comments[index]);
                        },
                      );
              },
              error: (err, st) => errorWidget(err, st),
              loading: () => AppLoader().stateLoader(),
            ),

            // Comment input box
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _buildCommentInput(),
      ),
    );
  }

  // Modern empty state

// Eye-catching sleek comment item
  Widget _buildCommentItem(Comment comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Modern avatar with shadow
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.redColor.withOpacity(0.2),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColor.redColor,
                          AppColor.redColor.withOpacity(0.6),
                        ],
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.grey.shade100,
                        // backgroundImage: comment.creator?.avatarUrl != null
                        //     ? NetworkImage(comment.creator!.avatarUrl!)
                        //     : null,
                        // child: comment.creator?.avatarUrl == null ||
                        //         comment.creator?.avatarUrl?.isEmpty == true
                        //     ? Icon(Icons.person,
                        //         size: 24, color: AppColor.redColor)
                        //     : null,
                        child: Icon(Icons.person,
                            size: 24, color: AppColor.redColor),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Comment content
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Username and timestamp in one line
                    Row(
                      children: [
                        Text(
                          comment.creator?.name ?? 'Unknown User',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: Colors.black,
                            letterSpacing: -0.3,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _formatTimestamp(comment.createdAt),
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Comment text with better styling
                    Text(
                      comment.content ?? '',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade800,
                        height: 1.5,
                        letterSpacing: 0.2,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Action buttons with icons
                    Row(
                      children: [
                        // _buildActionButton(
                        //   icon: Icons.chat_bubble_outline_rounded,
                        //   label: 'Reply',
                        //   onTap: () => _handleReply(comment),
                        // ),

                        TextButton(
                          onPressed: () => _handleReply(comment),
                          child: Text(
                            "Reply",
                            style: TextStyle(
                              color: AppColor.redColor,
                            ),
                          ),
                        ),

                        if (comment.subComments != null &&
                            comment.subComments!.isNotEmpty) ...[
                          const SizedBox(width: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.redColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${comment.subComments!.length} ${comment.subComments!.length == 1 ? 'reply' : 'replies'}',
                              style: TextStyle(
                                color: AppColor.redColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    // Sub-comments with connecting line
                    if (comment.subComments != null &&
                        comment.subComments!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 16, left: 12),
                        child: Column(
                          children: comment.subComments!
                              .map((subComment) =>
                                  _buildSubCommentItem(subComment))
                              .toList(),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          // Subtle divider
        ],
      ),
    );
  }

  // Action button widget
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Premium sub-comment item
  Widget _buildSubCommentItem(SubComment subComment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Connecting line
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                Container(
                  width: 2,
                  height: 20,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.grey.shade300,
                        Colors.grey.shade200,
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColor.redColor.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),

          // Avatar with glow effect
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColor.redColor.withOpacity(0.15),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey.shade100,
              backgroundImage: subComment.creator?.avatarUrl != null
                  ? NetworkImage(subComment.creator!.avatarUrl!)
                  : null,
              child: subComment.creator?.avatarUrl == null
                  ? Icon(Icons.person, size: 18, color: Colors.grey.shade400)
                  : null,
            ),
          ),
          const SizedBox(width: 12),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Username and time
              Row(
                children: [
                  Text(
                    subComment.creator?.name ?? 'Unknown User',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: Colors.black,
                      letterSpacing: -0.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 2.5,
                    height: 2.5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatTimestamp(subComment.createdAt),
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),

              // Reply content
              Text(
                subComment.content ?? '',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade800,
                  height: 1.5,
                  letterSpacing: 0.1,
                ),
              ),
              const SizedBox(height: 10),

              // Reply actions
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      width: double.infinity, // 👈 gives Row a real width
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_replyingToUsername != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.grey.shade50,
                child: Row(
                  children: [
                    Icon(Icons.reply_rounded,
                        size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      // 👈 prevents overflow here too
                      child: Text(
                        'Replying to $_replyingToUsername',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: _cancelReply,
                      child: Icon(Icons.close,
                          size: 18, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.grey.shade200,
                    child: Icon(Icons.person,
                        size: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(width: 12),

                  // 👇 THIS is the main fix
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _commentController,
                        focusNode: _commentFocusNode,
                        decoration: InputDecoration(
                          hintText: _replyingToUsername != null
                              ? 'Write a reply...'
                              : 'Add a comment...',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 15,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                        ),
                        style: TextStyle(fontSize: 15),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  GestureDetector(
                    onTap: _submitComment,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColor.redColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.send_rounded,
                          size: 20, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Handle reply to main comment
  void _handleReply(Comment comment) {
    setState(() {
      _replyingToCommentId = comment.commentId;
      _replyingToUsername = comment.creator?.name;
      isReply = true;
    });

    _commentFocusNode.requestFocus();
  }

  // Handle reply to sub-comment

  // Cancel reply
  void _cancelReply() {
    setState(() {
      _replyingToCommentId = null;
      _replyingToUsername = null;
      isReply = false;
    });
  }

  // Submit comment action
  void _submitComment() {
    if (_commentController.text.trim().isEmpty) return;

    final user = ref.watch(currentUserProvider);

    if (isReply) {
      final comment = SubComment(
        commentId: _replyingToCommentId,
        creator: CreatorModel(
          uid: user?.uid,
          name: user?.fullName,
          username: user?.username,
          avatarUrl: user?.avatar,
          profileHistory: null,
        ),
        content: _commentController.text,
      );

      ref
          .read(postCommentsProvider(widget.post.postId ?? '').notifier)
          .replyToComment(_replyingToCommentId ?? '', comment);
    } else {
      final comment = Comment(
        creator: CreatorModel(
          uid: user?.uid,
          name: user?.fullName,
          username: user?.username,
          avatarUrl: user?.avatar,
          profileHistory: null,
        ),
        content: _commentController.text,
      );

      ref
          .read(postCommentsProvider(widget.post.postId ?? '').notifier)
          .createComment(comment);
    }

    _commentController.clear();
    _cancelReply();
  }

  // Helper method to format timestamp (Instagram-style)
  String _formatTimestamp(int? timestamp) {
    if (timestamp == null) return '';

    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}
