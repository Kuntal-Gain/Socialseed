import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialseed/domain/entities/user_entity.dart';
import 'package:socialseed/features/services/theme_service.dart';
import 'package:socialseed/utils/constants/color_const.dart';
import 'package:socialseed/utils/constants/page_const.dart';
import 'package:socialseed/utils/constants/text_const.dart';

import '../../utils/constants/tags_const.dart';

Widget messageTileWidget(UserEntity friend, UserEntity current,
    String lastMessage, BuildContext context, int unreadMsgCount) {
  final textColor = Provider.of<ThemeService>(context).isDarkMode
      ? AppColor.whiteColor
      : AppColor.blackColor;

  return SizedBox(
    width: double.infinity,
    child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            // pfp
            ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Image.network(
                friend.imageUrl!,
                fit: BoxFit.cover,
                height: 64,
                width: 64,
              ),
            ),

            sizeHor(10),
            // name

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        friend.username!,
                        style: TextConst.headingStyle(
                          16,
                          textColor,
                        ),
                      ),
                      if (friend.work!.toLowerCase() != "none" &&
                          current.work!.toLowerCase() ==
                              friend.work!.toLowerCase())
                        mutualTag("work"),
                      if (friend.school!.toLowerCase() != "none" &&
                          current.school!.toLowerCase() ==
                              friend.school!.toLowerCase())
                        mutualTag("school"),
                      if (friend.college!.toLowerCase() != "none" &&
                          current.college!.toLowerCase() ==
                              friend.college!.toLowerCase())
                        mutualTag("college"),
                      if (friend.location!.toLowerCase() != "none" &&
                          current.location!.toLowerCase() ==
                              friend.location!.toLowerCase())
                        mutualTag("home"),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(lastMessage,
                          style: TextConst.RegularStyle(
                            16,
                            textColor,
                          )),
                      if (unreadMsgCount > 0)
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: AppColor.redColor,
                          child: Text(
                            unreadMsgCount.toString(),
                            style: TextConst.headingStyle(
                              12,
                              AppColor.whiteColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        )),
  );
}
