import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:socialseed/app/widgets/view_post_widget.dart';
import 'package:socialseed/utils/constants/color_const.dart';
import 'package:socialseed/utils/constants/text_const.dart';

Widget notificationCard(String? imageUrl, String message, Timestamp time,
    String type, Color color) {
  return Container(
    margin: const EdgeInsets.all(12),
    child: Row(
      children: [
        Stack(
          children: [
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: imageUrl != null
                    ? Image.network(
                        imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: AppColor.greyShadowColor,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppColor.redColor,
                          ),
                        ),
                      ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: getIcon(type),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          // Added Expanded widget
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: TextConst.headingStyle(16, color),
                overflow: TextOverflow.visible,
              ),
              const SizedBox(height: 10),
              Text(
                getTime(time),
                style: TextConst.headingStyle(14, color),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget getIcon(String type) {
  IconData icon = Icons.favorite;

  switch (type.toLowerCase()) {
    case 'follow':
      icon = Icons.people;
      break;
    case 'friend_request':
      icon = Icons.group_add;
      break;
    case 'like':
      icon = Icons.favorite;
      break;
    case 'comment':
      icon = Icons.comment;
      break;
    default:
      icon = Icons.favorite;
      break;
  }

  return Icon(
    icon,
    color: AppColor.redColor,
    size: 32,
  );
}
