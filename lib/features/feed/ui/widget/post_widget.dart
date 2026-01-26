import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:socialseed/core/utils/constants/color_const.dart';
import 'package:socialseed/core/utils/helpers/screen_utils.dart';
import 'package:socialseed/core/utils/helpers/text_style.dart';

class PostWidget extends StatelessWidget {
  final bool isImage;
  const PostWidget({super.key, required this.isImage});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                        const Text(
                          'Akane Tachibana',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '• 1 hour ago',
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
          const Text(
            'Money , It has changed our entire family\'s lifestyle. It has brought us so much of happiness. Also, the love is there too, feels good, when people hit me up at most places and appreciate the content :)',
            style: TextStyle(
              fontSize: 15,
              color: Colors.black87,
              height: 1.5,
            ),
          ),

          sizeVer(8),

          if (isImage)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset('assets/temp/temp-1.jpg'),
            ),

          const SizedBox(height: 16),
          // Action Buttons
          Row(
            children: [
              // Like Button
              Row(
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 22,
                    color: Colors.grey.shade700,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '2,321',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              // Comment Button
              Row(
                children: [
                  Icon(
                    Ionicons.chatbox_outline,
                    size: 22,
                    color: Colors.grey.shade700,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '102',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              // Share Button
            ],
          ),
        ],
      ),
    );
  }
}
