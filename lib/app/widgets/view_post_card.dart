import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/services/theme_service.dart';
import '../../utils/constants/color_const.dart';

Widget postItem(
    {required String iconId,
    required num? value,
    required BuildContext context}) {
  return Row(
    children: [
      Container(
        height: 25,
        width: 25,
        margin: const EdgeInsets.all(12),
        child: Image.asset(
          iconId,
          color: Provider.of<ThemeService>(context).isDarkMode
              ? AppColor.whiteColor
              : AppColor.blackColor,
        ),
      ),
      Text(
        value.toString(),
        style: const TextStyle(
          color: Colors.grey,
        ),
      ),
    ],
  );
}
