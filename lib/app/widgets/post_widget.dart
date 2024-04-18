import 'package:flutter/material.dart';
import 'package:socialseed/utils/constants/color_const.dart';
import 'package:socialseed/utils/constants/text_const.dart';

Widget getLocation(String loc) {
  return Row(
    children: [
      const Text('in'),
      const SizedBox(width: 10),
      Text(
        loc,
        style: TextConst.MediumStyle(14, AppColor.blackColor),
      ),
    ],
  );
}

Widget getTagUsers(List<String> tags) {
  return Text(
    '+${tags.length}',
    style: const TextStyle(
      color: AppColor.redColor,
    ),
  );
}
