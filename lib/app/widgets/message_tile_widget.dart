import 'package:flutter/material.dart';
import 'package:socialseed/domain/entities/user_entity.dart';
import 'package:socialseed/utils/constants/color_const.dart';
import 'package:socialseed/utils/constants/page_const.dart';
import 'package:socialseed/utils/constants/text_const.dart';

import '../../utils/constants/tags_const.dart';

Widget messageTileWidget(
    UserEntity friend, UserEntity current, String lastMessage) {
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
                CircleAvatar(
                  radius: 32,
                  backgroundImage: NetworkImage(
                    friend.imageUrl!,
                  ),
                ),
                sizeHor(10),
                // name
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          friend.username!,
                          style: TextConst.headingStyle(
                            16,
                            AppColor.blackColor,
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
                    Text(lastMessage),
                  ],
                ),
              ],
            ),
          ],
        )),
  );
}
