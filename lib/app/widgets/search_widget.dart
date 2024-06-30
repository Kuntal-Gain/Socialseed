import 'package:flutter/material.dart';
import 'package:socialseed/domain/entities/user_entity.dart';
import 'package:socialseed/utils/constants/color_const.dart';
import 'package:socialseed/utils/constants/page_const.dart';
import 'package:socialseed/utils/constants/text_const.dart';

Widget searchWidget(UserEntity user) {
  return Container(
    margin: const EdgeInsets.all(12),
    child: Row(
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(user.imageUrl.toString()),
          radius: 30,
        ),
        sizeHor(5),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.fullname.toString(),
              style: TextConst.headingStyle(16, AppColor.blackColor),
            ),
            Text("@${user.username}"),
          ],
        ),
      ],
    ),
  );
}
