import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:socialseed/core/utils/constants/color_const.dart';
import 'package:socialseed/core/utils/helpers/app_loader.dart';
import 'package:socialseed/core/utils/helpers/datetime_helper.dart';
import 'package:socialseed/core/utils/helpers/failure_widget.dart';
import 'package:socialseed/core/utils/helpers/screen_utils.dart';
import 'package:socialseed/core/utils/helpers/text_style.dart';
import 'package:socialseed/features/post/model/post_model.dart';
import 'package:socialseed/features/post/ui/provider/post_provider.dart';

import '../../../../core/services/route_generator.dart';

class PostWidget extends ConsumerWidget {
  final PostModel post;
  const PostWidget({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likeAsync = ref.watch(postLikeProvider(post.postId ?? ''));
    final commentAsync = ref.watch(postCommentsProvider(post.postId ?? ''));

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, RouteGenerator.kPostView, arguments: {
          'post': post,
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Picture
                const CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(
                    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&h=150&fit=crop',
                  ),
                ),
                const SizedBox(width: 12),
                // Name and Time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            post.creator?.name ?? '',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '• ${TimeHelper.timeAgo(post.createdAt ?? Timestamp.now())}', //TODO: releative time
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0x4DF55050),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'college',
                          style: appTextStyle(
                            color: AppColor.whiteColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Menu Icon
                Icon(
                  Ionicons.ellipsis_horizontal,
                  color: Colors.grey.shade700,
                  size: 28,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Post Content
            Text(
              post.content ?? '',
              style: TextStyle(
                fontSize: 15,
                color: Colors.black87,
                height: 1.5,
              ),
            ),

            sizeVer(8),

            if (post.type == PostType.image)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  post.assets?.first ?? '',
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;

                    // Gray shimmer-like placeholder
                    return Container(
                      height: 220,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                      ),
                    );
                  },
                  errorBuilder: (ctx, err, st) {
                    return Container(
                      height: 220,
                      width: double.infinity,
                      color: Colors.grey.shade300,
                      child: const Center(
                        child: Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 16),
            // Action Buttons
            Row(
              children: [
                // Like Button

                likeAsync.when(
                  data: (like) {
                    return Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            ref
                                .read(postLikeProvider(post.postId ?? '')
                                    .notifier)
                                .toggleLike();
                          },
                          child: Icon(
                            like.isLikedByMe
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 22,
                            color: like.isLikedByMe
                                ? AppColor.redColor
                                : Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          like.count.toString(),
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    );
                  },
                  error: (err, st) => SizedBox.shrink(),
                  loading: () => SizedBox.shrink(),
                ),

                const SizedBox(width: 24),
                // Comment Button
                commentAsync.when(
                  data: (comments) {
                    return Row(
                      children: [
                        Icon(
                          Ionicons.chatbox_outline,
                          size: 22,
                          color: Colors.grey.shade700,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${comments.length}',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    );
                  },
                  error: (err, st) => SizedBox.shrink(),
                  loading: () => SizedBox.shrink(),
                ),
                const SizedBox(width: 24),
                // Share Button
              ],
            ),
          ],
        ),
      ),
    );
  }
}
