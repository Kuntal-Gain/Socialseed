import 'package:flutter/material.dart';
import 'package:socialseed/utils/constants/color_const.dart';
import 'package:socialseed/utils/constants/text_const.dart';

List<Color> colors = <Color>[
  const Color.fromARGB(255, 144, 205, 255),
  const Color.fromARGB(255, 237, 144, 255),
  const Color.fromARGB(255, 144, 255, 168),
  const Color.fromARGB(255, 255, 144, 144),
  Colors.transparent,
];

Widget mutualTag(String role) {
  Color color = colors[0];

  switch (role.toString()) {
    case "home":
      color = colors[0];
      break;
    case "school":
      color = colors[1];
      break;
    case "college":
      color = colors[2];
      break;
    case "work":
      color = colors[3];
      break;
    default:
      color = colors[4];
      break;
  }

  return Container(
    width: 75,
    height: 20,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(16),
    ),
    margin: const EdgeInsets.all(5),
    child: Center(
      child: Text(
        role,
        style: TextConst.headingStyle(
          14,
          AppColor.whiteColor,
        ),
      ),
    ),
  );
}
