import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialseed/features/services/theme_service.dart';

import '../../utils/constants/color_const.dart';
import '../../utils/constants/text_const.dart';

Widget infoCard(IconData icon, String info, String brand, Color textColor) {
  return Row(
    children: [
      IconButton(
        onPressed: () {},
        icon: Icon(
          icon,
          color: AppColor.redColor,
        ),
      ),
      if (brand.toLowerCase() == "none")
        Text(
          'Nothing',
          style: TextStyle(color: textColor),
        ),
      if (brand.toLowerCase() != "none")
        Flexible(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  info,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textColor,
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  brand,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
    ],
  );
}

Widget getButton(String label, Function()? onClick, bool isColorExists,
    BuildContext context) {
  final shadow = (Provider.of<ThemeService>(context).isDarkMode)
      ? AppColor.blackColor
      : AppColor.greyShadowColor;

  final textColor = (Provider.of<ThemeService>(context).isDarkMode)
      ? AppColor.blackColor
      : AppColor.whiteColor;

  final secondaryColor = (Provider.of<ThemeService>(context).isDarkMode)
      ? AppColor.secondaryDark
      : AppColor.whiteColor;

  return GestureDetector(
    onTap: onClick,
    child: Container(
      height: 60,
      width: double.infinity,
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: isColorExists ? secondaryColor : AppColor.redColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: shadow,
              blurRadius: 5,
            ),
          ]),
      child: Center(
          child: Text(
        label,
        style: TextConst.headingStyle(
          18,
          !isColorExists ? textColor : AppColor.redColor,
        ),
        overflow: TextOverflow.ellipsis,
      )),
    ),
  );
}
