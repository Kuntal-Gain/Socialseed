import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialseed/app/screens/user/user_profile.dart';
import 'package:socialseed/domain/entities/user_entity.dart';
import 'package:socialseed/features/services/theme_service.dart';
import 'package:socialseed/utils/constants/color_const.dart';
import 'package:socialseed/utils/constants/page_const.dart';
import 'package:socialseed/utils/constants/text_const.dart';

Widget searchWidget({required UserEntity user, required BuildContext ctx}) {
  final color = Provider.of<ThemeService>(ctx).isDarkMode
      ? AppColor.whiteColor
      : AppColor.blackColor;

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
              style: TextConst.headingStyle(18, color),
            ),
            Text(
              "@${user.username}",
              style: TextConst.headingStyle(14, AppColor.redColor),
            ),
          ],
        ),
      ],
    ),
  );
}
