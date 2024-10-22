import 'package:flutter/material.dart';
import 'package:socialseed/domain/entities/user_entity.dart';
import 'package:socialseed/utils/constants/color_const.dart';
import 'package:socialseed/utils/constants/page_const.dart';
import 'package:socialseed/utils/constants/text_const.dart';

Widget getLocation(String loc) {
  return Row(
    children: [
      const Text('in'),
      sizeHor(5),
      Text(
        loc,
        style: TextConst.MediumStyle(14, AppColor.blackColor),
      ),
    ],
  );
}

Widget getTagUsers(List<UserEntity> tags) {
  return Text(
    '+${tags.length}',
    style: const TextStyle(
      color: AppColor.redColor,
    ),
  );
}
