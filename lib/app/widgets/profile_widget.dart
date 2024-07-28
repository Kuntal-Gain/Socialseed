import 'package:flutter/material.dart';

import '../../utils/constants/color_const.dart';
import '../../utils/constants/text_const.dart';

Widget infoCard(IconData icon, String info, String brand) {
  return Row(
    children: [
      IconButton(
        onPressed: () {},
        icon: Icon(
          icon,
          color: AppColor.redColor,
        ),
      ),
      if (brand.toLowerCase() == "none") const Text('Nothing'),
      if (brand.toLowerCase() != "none")
        Flexible(
          child: Row(
            children: [
              Flexible(
                child: Text(info, overflow: TextOverflow.ellipsis),
              ),
              Flexible(
                child: Text(
                  brand,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
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

Widget getButton(String label, Function()? onClick, bool isColorExists) {
  return GestureDetector(
    onTap: onClick,
    child: Container(
      height: 60,
      width: double.infinity,
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: isColorExists ? AppColor.whiteColor : AppColor.redColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColor.greyShadowColor)),
      child: Center(
          child: Text(
        label,
        style: TextConst.headingStyle(
          18,
          !isColorExists ? AppColor.whiteColor : AppColor.redColor,
        ),
        overflow: TextOverflow.ellipsis,
      )),
    ),
  );
}
