// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:socialseed/core/utils/constants/color_const.dart';
// import 'package:socialseed/core/utils/helpers/screen_utils.dart';
// import 'package:socialseed/features/auth_module/model/user_model.dart';
// import 'package:socialseed/features/auth_module/ui/provider/creds_provider.dart';

// class StoryCard extends ConsumerWidget {
//   final bool isAddStory;
//   final String? imageUrl;
//   final String? uid;
//   final bool? isViewed;

//   const StoryCard({
//     super.key,
//     this.isAddStory = false,
//     this.imageUrl,
//     this.uid,
//     this.isViewed = false,
//   });

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final double cardHeight = ScreenUtils().screenHeight(context) * 0.12;
//     final double cardWidth = ScreenUtils().screenWidth(context) * 0.235;

//     final userAsync = ref.watch(userByIdProvider(uid ?? ""));

//     return userAsync.when(
//       data: (user) {
//         print("User: ${user?.avatar}");
//         return SizedBox(
//           width: cardWidth,
//           height: cardHeight + (isAddStory ? 16 : 0),
//           child: Stack(
//             clipBehavior: Clip.none,
//             children: [
//               // Main Story Card Container
//               Container(
//                 width: cardWidth,
//                 height: cardHeight,
//                 margin: const EdgeInsets.symmetric(horizontal: 10),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(
//                     color: isAddStory
//                         ? Colors.grey.shade300
//                         : (isViewed ?? false)
//                             ? Colors.grey.shade300
//                             : AppColor.redColor,
//                     width: isAddStory ? 1 : 2.5,
//                   ),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.08),
//                       blurRadius: 8,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(18),
//                   child: user?.avatar != null
//                       ? Image.network(
//                           user?.avatar ?? "",
//                           fit: BoxFit.cover,
//                           errorBuilder: (context, error, stackTrace) {
//                             return Container(
//                               color: Colors.grey.shade200,
//                               child: Icon(
//                                 Icons.person,
//                                 size: 40,
//                                 color: Colors.grey.shade400,
//                               ),
//                             );
//                           },
//                         )
//                       : Container(
//                           color: Colors.grey.shade100,
//                           child: Icon(
//                             Icons.person,
//                             size: 40,
//                             color: Colors.grey.shade300,
//                           ),
//                         ),
//                 ),
//               ),

//               // Add Story Button (Red circle with plus icon)
//               if (isAddStory)
//                 Positioned(
//                   right: 3,
//                   bottom: 16,
//                   child: Container(
//                     height: 32,
//                     width: 32,
//                     decoration: BoxDecoration(
//                       color: AppColor.redColor,
//                       shape: BoxShape.circle,
//                       border: Border.all(
//                         color: Colors.white,
//                         width: 2,
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.2),
//                           blurRadius: 8,
//                           offset: const Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: const Icon(
//                       Icons.add,
//                       size: 20,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         );
//       },
//       loading: () => const SizedBox.shrink(),
//       error: (error, stackTrace) => const SizedBox.shrink(),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socialseed/features/auth_module/ui/provider/creds_provider.dart';

class StoryCard extends ConsumerWidget {
  final bool isAddStory;
  final String? uid;
  final bool? isViewed;

  const StoryCard({
    super.key,
    this.isAddStory = false,
    this.uid,
    this.isViewed = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userByIdProvider(uid ?? ''));

    return userAsync.when(
      data: (user) => _StoryCardBody(
        isAddStory: isAddStory,
        isViewed: isViewed ?? false,
        avatarUrl: user?.avatar,
        name: user?.fullName?.split(' ').first ?? '',
      ),
      loading: () => const _StoryCardShimmer(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _StoryCardBody extends StatelessWidget {
  final bool isAddStory;
  final bool isViewed;
  final String? avatarUrl;
  final String name;

  const _StoryCardBody({
    required this.isAddStory,
    required this.isViewed,
    this.avatarUrl,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    const double size = 58;

    final ringColor = isAddStory
        ? const Color(0xFFE8E8E8)
        : isViewed
            ? const Color(0xFFDDDDDD)
            : Colors.black;

    return Container(
      width: 68,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Ring
              Container(
                width: size + 6,
                height: size + 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ringColor,
                    width: isAddStory ? 1 : 2,
                  ),
                ),
              ),
              // Avatar
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF2F2F2),
                  image: avatarUrl != null && avatarUrl!.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(avatarUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: avatarUrl == null || avatarUrl!.isEmpty
                    ? const Icon(Icons.person,
                        size: 24, color: Color(0xFFCCCCCC))
                    : null,
              ),
              // Add badge
              if (isAddStory)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.add, size: 12, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            isAddStory ? 'Add' : name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isViewed && !isAddStory
                  ? const Color(0xFFBBBBBB)
                  : const Color(0xFF333333),
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryCardShimmer extends StatelessWidget {
  const _StoryCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF0F0F0),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 36,
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
