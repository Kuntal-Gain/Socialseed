import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socialseed/core/utils/constants/color_const.dart';
import 'package:socialseed/core/utils/helpers/screen_utils.dart';
import 'package:socialseed/features/auth_module/model/user_model.dart';
import 'package:socialseed/features/auth_module/ui/provider/creds_provider.dart';

class StoryCard extends ConsumerWidget {
  final bool isAddStory;
  final String? imageUrl;
  final String? uid;
  final bool? isViewed;

  const StoryCard({
    super.key,
    this.isAddStory = false,
    this.imageUrl,
    this.uid,
    this.isViewed = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double cardHeight = ScreenUtils().screenHeight(context) * 0.12;
    final double cardWidth = ScreenUtils().screenWidth(context) * 0.235;

    final userAsync = ref.watch(userByIdProvider(uid ?? ""));

    return userAsync.when(
      data: (user) {
        print("User: ${user?.avatar}");
        return SizedBox(
          width: cardWidth,
          height: cardHeight + (isAddStory ? 16 : 0),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Main Story Card Container
              Container(
                width: cardWidth,
                height: cardHeight,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isAddStory
                        ? Colors.grey.shade300
                        : (isViewed ?? false)
                            ? Colors.grey.shade300
                            : AppColor.redColor,
                    width: isAddStory ? 1 : 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: user?.avatar != null
                      ? Image.network(
                          user?.avatar ?? "",
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade200,
                              child: Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.grey.shade400,
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey.shade100,
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.grey.shade300,
                          ),
                        ),
                ),
              ),

              // Add Story Button (Red circle with plus icon)
              if (isAddStory)
                Positioned(
                  right: 3,
                  bottom: 16,
                  child: Container(
                    height: 32,
                    width: 32,
                    decoration: BoxDecoration(
                      color: AppColor.redColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }
}
