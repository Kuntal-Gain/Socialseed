import 'package:flutter/material.dart';
import 'package:socialseed/utils/constants/color_const.dart';
import 'package:socialseed/utils/constants/page_const.dart';
import 'package:socialseed/utils/constants/text_const.dart';

Widget taggedWidgetTile(
    {required String tag,
    required Size size,
    required int count,
    required Function() onClick}) {
  return Container(
    height: size.height * 0.15,
    width: size.width,
    decoration: BoxDecoration(
      color: AppColor.redColor,
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(16),
        bottomRight: Radius.circular(16),
      ),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: onClick,
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: AppColor.whiteColor,
              ),
            ),
            Text(
              tag,
              style: TextConst.headingStyle(
                  size.width * 0.06, AppColor.whiteColor),
            ),
          ],
        ),
        sizeVar(10),
        Padding(
          padding: EdgeInsets.only(left: size.width * 0.05),
          child: Text('$count Posts',
              style: TextConst.headingStyle(
                  size.width * 0.04, AppColor.whiteColor)),
        ),
      ],
    ),
  );
}
