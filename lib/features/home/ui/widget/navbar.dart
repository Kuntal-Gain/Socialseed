import 'package:flutter/material.dart';
import 'package:socialseed/core/utils/constants/color_const.dart';

class SocialBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const SocialBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      Icons.home_rounded,
      Icons.group_rounded,
      Icons.explore_rounded,
      Icons.notifications_rounded,
      Icons.person_rounded,
    ];

    return Container(
      height: 75,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 20,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(items.length, (index) {
          final isSelected = currentIndex == index;

          return GestureDetector(
            onTap: () => onTap(index),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColor.redColor : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
              ),
              child: AnimatedScale(
                scale: isSelected ? 1.2 : 1.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                child: Icon(
                  items[index],
                  size: 26,
                  color: isSelected ? Colors.white : Colors.grey,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
