// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:ionicons/ionicons.dart';
// import 'package:socialseed/core/utils/constants/color_const.dart';
// import 'package:socialseed/core/utils/helpers/app_loader.dart';
// import 'package:socialseed/core/utils/helpers/datetime_helper.dart';
// import 'package:socialseed/core/utils/helpers/failure_widget.dart';
// import 'package:socialseed/core/utils/helpers/screen_utils.dart';
// import 'package:socialseed/core/utils/helpers/text_style.dart';
// import 'package:socialseed/features/auth_module/model/user_model.dart';
// import 'package:socialseed/features/auth_module/ui/provider/creds_provider.dart';
// import 'package:socialseed/features/post/model/post_model.dart';
// import 'package:socialseed/features/post/ui/provider/post_provider.dart';
// import 'package:socialseed/features/post/ui/widget/relationship_chip.dart';

// import '../../../../core/services/route_generator.dart';

// class PostWidget extends ConsumerWidget {
//   final PostModel post;
//   final bool isFeed;
//   const PostWidget({
//     super.key,
//     required this.post,
//     this.isFeed = false,
//   });

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final likeAsync = ref.watch(postLikeProvider(post.postId ?? ''));
//     final commentAsync = ref.watch(postCommentsProvider(post.postId ?? ''));

//     final userAsync = ref.watch(userByIdProvider(post.creatorUid ?? ''));

//     final user = userAsync.maybeWhen(
//       orElse: () => null,
//       data: (user) => user,
//     );

//     return GestureDetector(
//       onTap: () {
//         if (isFeed) {
//           Navigator.pushNamed(context, RouteGenerator.kPostView, arguments: {
//             'post': post,
//           });
//         }
//       },
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: Colors.grey.shade200),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 10,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Profile Picture
//                 CircleAvatar(
//                   radius: 24,
//                   backgroundImage: NetworkImage(
//                     user?.avatar ?? '',
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 // Name and Time
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Text(
//                             user?.fullName ?? '',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.black,
//                             ),
//                           ),
//                           const SizedBox(width: 6),
//                           Text(
//                             '• ${TimeHelper.timeAgo(post.createdAt ?? Timestamp.now())}', //TODO: releative time
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.grey.shade500,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 6),
//                       if (post.creatorUid !=
//                           FirebaseAuth.instance.currentUser?.uid)
//                         RelationshipChip(
//                           friendProfileHistory: user?.profileHistory ??
//                               ProfileHistory(
//                                 "",
//                                 "",
//                                 "",
//                               ),
//                         )
//                       else
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 10, vertical: 6),
//                           decoration: BoxDecoration(
//                             color: Colors.red.shade100,
//                             borderRadius: BorderRadius.circular(20),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.red.withOpacity(0.05),
//                                 blurRadius: 10,
//                                 offset: const Offset(0, 2),
//                               ),
//                             ],
//                           ),
//                           child: Text(
//                             "You",
//                             style: TextStyle(
//                               color: Colors.red,
//                               fontSize: 11,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//                 // Menu Icon
//                 Icon(
//                   Ionicons.ellipsis_horizontal,
//                   color: Colors.grey.shade700,
//                   size: 28,
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             // Post Content
//             Text(
//               post.content ?? '',
//               style: TextStyle(
//                 fontSize: 15,
//                 color: Colors.black87,
//                 height: 1.5,
//               ),
//             ),

//             sizeVer(8),

//             if (post.type == PostType.image)
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child: Image.network(
//                   post.assets?.first ?? '',
//                   fit: BoxFit.cover,
//                   height: ScreenUtils().screenHeight(context) * 0.25,
//                   width: ScreenUtils().screenWidth(context) * 0.9,
//                   loadingBuilder: (context, child, loadingProgress) {
//                     if (loadingProgress == null) return child;

//                     // Gray shimmer-like placeholder
//                     return Container(
//                       height: 220,
//                       width: double.infinity,
//                       decoration: BoxDecoration(
//                         color: Colors.grey.shade300,
//                       ),
//                     );
//                   },
//                   errorBuilder: (ctx, err, st) {
//                     return Container(
//                       height: 220,
//                       width: double.infinity,
//                       color: Colors.grey.shade300,
//                       child: const Center(
//                         child: Icon(Icons.broken_image, color: Colors.grey),
//                       ),
//                     );
//                   },
//                 ),
//               ),

//             const SizedBox(height: 16),
//             // Action Buttons
//             Row(
//               children: [
//                 // Like Button

//                 likeAsync.when(
//                   data: (like) {
//                     return Row(
//                       children: [
//                         GestureDetector(
//                           onTap: () {
//                             ref
//                                 .read(postLikeProvider(post.postId ?? '')
//                                     .notifier)
//                                 .toggleLike();
//                           },
//                           child: Icon(
//                             like.isLikedByMe
//                                 ? Icons.favorite
//                                 : Icons.favorite_border,
//                             size: 22,
//                             color: like.isLikedByMe
//                                 ? AppColor.redColor
//                                 : Colors.grey.shade700,
//                           ),
//                         ),
//                         const SizedBox(width: 6),
//                         Text(
//                           like.count.toString(),
//                           style: TextStyle(
//                             fontSize: 15,
//                             color: Colors.grey.shade800,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ],
//                     );
//                   },
//                   error: (err, st) => SizedBox.shrink(),
//                   loading: () => SizedBox.shrink(),
//                 ),

//                 const SizedBox(width: 24),
//                 // Comment Button
//                 commentAsync.when(
//                   data: (comments) {
//                     return Row(
//                       children: [
//                         Icon(
//                           Ionicons.chatbox_outline,
//                           size: 22,
//                           color: Colors.grey.shade700,
//                         ),
//                         const SizedBox(width: 6),
//                         Text(
//                           '${comments.length}',
//                           style: TextStyle(
//                             fontSize: 15,
//                             color: Colors.grey.shade800,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ],
//                     );
//                   },
//                   error: (err, st) => SizedBox.shrink(),
//                   loading: () => SizedBox.shrink(),
//                 ),
//                 const SizedBox(width: 24),
//                 // Share Button
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:socialseed/core/utils/constants/color_const.dart';
import 'package:socialseed/core/utils/helpers/datetime_helper.dart';
import 'package:socialseed/core/utils/helpers/screen_utils.dart';
import 'package:socialseed/features/auth_module/model/user_model.dart';
import 'package:socialseed/features/auth_module/ui/provider/creds_provider.dart';
import 'package:socialseed/features/post/model/post_model.dart';
import 'package:socialseed/features/post/ui/provider/post_provider.dart';
import 'package:socialseed/features/post/ui/widget/relationship_chip.dart';
import 'package:socialseed/core/services/route_generator.dart';

class PostWidget extends ConsumerWidget {
  final PostModel post;
  final bool isFeed;

  const PostWidget({
    super.key,
    required this.post,
    this.isFeed = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likeAsync = ref.watch(postLikeProvider(post.postId ?? ''));
    final commentAsync = ref.watch(postCommentsProvider(post.postId ?? ''));
    final userAsync = ref.watch(userByIdProvider(post.creatorUid ?? ''));

    final user = userAsync.maybeWhen(orElse: () => null, data: (u) => u);
    final isOwn = post.creatorUid == FirebaseAuth.instance.currentUser?.uid;

    return GestureDetector(
      onTap: () {
        if (isFeed) {
          Navigator.pushNamed(context, RouteGenerator.kPostView,
              arguments: {'post': post});
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF0F0F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(user, isOwn),
            if ((post.content ?? '').isNotEmpty) _buildContent(),
            if (post.type == PostType.image) _buildImage(context),
            _buildActions(ref, likeAsync, commentAsync),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(User? user, bool isOwn) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _Avatar(url: user?.avatar),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user?.fullName ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (isOwn) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColor.redColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'YOU',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  TimeHelper.timeAgo(post.createdAt ?? Timestamp.now()),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFAAAAAA),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          if (!isOwn)
            RelationshipChip(
              friendProfileHistory:
                  user?.profileHistory ?? ProfileHistory('', '', ''),
            ),
          const SizedBox(width: 8),
          Icon(Ionicons.ellipsis_horizontal,
              color: const Color(0xFFCCCCCC), size: 20),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Text(
        post.content ?? '',
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF222222),
          height: 1.55,
          letterSpacing: -0.1,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          post.assets?.first ?? '',
          fit: BoxFit.cover,
          height: ScreenUtils().screenHeight(context) * 0.24,
          width: double.infinity,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(
              height: ScreenUtils().screenHeight(context) * 0.24,
              color: const Color(0xFFF2F2F2),
            );
          },
          errorBuilder: (_, __, ___) => Container(
            height: 180,
            color: const Color(0xFFF2F2F2),
            child: const Center(
              child: Icon(Icons.image_not_supported_outlined,
                  color: Color(0xFFCCCCCC), size: 28),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActions(
      WidgetRef ref, AsyncValue likeAsync, AsyncValue commentAsync) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Row(
        children: [
          likeAsync.when(
            data: (like) => _ActionBtn(
              icon: like.isLikedByMe ? Icons.favorite : Icons.favorite_border,
              label: '${like.count}',
              active: like.isLikedByMe,
              onTap: () => ref
                  .read(postLikeProvider(post.postId ?? '').notifier)
                  .toggleLike(),
            ),
            error: (_, __) => const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
          ),
          const SizedBox(width: 20),
          commentAsync.when(
            data: (comments) => _ActionBtn(
              icon: Ionicons.chatbox_outline,
              label: '${comments.length}',
              active: false,
              onTap: null,
            ),
            error: (_, __) => const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
          ),
          const Spacer(),
          _ActionBtn(
            icon: Ionicons.share_outline,
            label: '',
            active: false,
            onTap: null,
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? url;
  const _Avatar({this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFF0F0F0),
        image: url != null && url!.isNotEmpty
            ? DecorationImage(image: NetworkImage(url!), fit: BoxFit.cover)
            : null,
      ),
      child: url == null || url!.isEmpty
          ? const Icon(Icons.person, size: 20, color: Color(0xFFCCCCCC))
          : null,
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: active ? AppColor.redColor : const Color(0xFFAAAAAA),
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: active ? Colors.black : const Color(0xFFAAAAAA),
                letterSpacing: -0.2,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
