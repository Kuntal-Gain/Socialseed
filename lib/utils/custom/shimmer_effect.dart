import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../features/services/theme_service.dart';
import '../constants/color_const.dart';
import '../constants/page_const.dart';

Widget shimmerEffectPost(BuildContext ctx) {
  final isDark = Provider.of<ThemeService>(ctx).isDarkMode;

  // 🎨 Dynamic shimmer colors
  final baseShimmer = isDark ? Colors.grey[800]! : Colors.grey[300]!;
  final highlightShimmer = isDark ? Colors.grey[700]! : Colors.grey[100]!;
  final containerColor = isDark ? Colors.grey[900]! : Colors.white;

  return Container(
    height: 350,
    width: double.infinity,
    margin: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      boxShadow: const [
        BoxShadow(
          color: AppColor.greyShadowColor,
          spreadRadius: 1,
          blurRadius: 1,
        ),
      ],
      color: containerColor,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Shimmer.fromColors(
                    baseColor: baseShimmer,
                    highlightColor: highlightShimmer,
                    child: CircleAvatar(
                      backgroundColor: containerColor,
                      radius: 20.0,
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Shimmer.fromColors(
                            baseColor: baseShimmer,
                            highlightColor: highlightShimmer,
                            child: Container(
                              height: 20,
                              width: 100,
                              color: containerColor,
                            ),
                          ),
                          sizeHor(5),
                          Shimmer.fromColors(
                            baseColor: baseShimmer,
                            highlightColor: highlightShimmer,
                            child: Container(
                              height: 20,
                              width: 70,
                              color: containerColor,
                            ),
                          ),
                        ],
                      ),
                      sizeVar(5),
                      Shimmer.fromColors(
                        baseColor: baseShimmer,
                        highlightColor: highlightShimmer,
                        child: Container(
                          height: 20,
                          width: 150,
                          color: containerColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: Shimmer.fromColors(
            baseColor: baseShimmer,
            highlightColor: highlightShimmer,
            child: Container(
              height: 20,
              margin: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: containerColor,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        Row(
          children: [
            sizeHor(10),
            Shimmer.fromColors(
              baseColor: baseShimmer,
              highlightColor: highlightShimmer,
              child: Container(
                height: 40,
                width: 160,
                margin: const EdgeInsets.all(12),
                color: containerColor,
              ),
            ),
          ],
        )
      ],
    ),
  );
}

Widget shimmerEffectFriends() {
  return Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColor.greyShadowColor,
          width: 5,
        ),
      ),
      child: CircleAvatar(
        radius: 35,
        backgroundColor: Colors.white,
        child: ClipOval(
          child: Container(
            width: 70,
            height: 70,
            color: Colors.white,
          ),
        ),
      ),
    ),
  );
}

Widget shimmerEffectChat() {
  return SizedBox(
    width: double.infinity,
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // pfp
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: const CircleAvatar(),
              ),
              sizeHor(10),
              // name
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          width: 120,
                          height: 20,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  sizeVar(4),
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 160,
                      height: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget shimmerEffectNotification() {
  return Container(
    margin: const EdgeInsets.all(12),
    child: Row(
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: double.infinity,
                  height: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 100,
                  height: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
