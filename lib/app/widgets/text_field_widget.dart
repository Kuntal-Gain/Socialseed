import 'package:flutter/material.dart';
import 'package:socialseed/utils/constants/color_const.dart';

Widget getTextField(
    TextEditingController controller, String label, TextInputType key) {
  return Container(
    height: 66,
    width: double.infinity,
    margin: const EdgeInsets.all(5),
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
    decoration: BoxDecoration(
      color: AppColor.greyColor,
      borderRadius: BorderRadius.circular(14),
    ),
    child: TextField(
      controller: controller,
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: label,
      ),
    ),
  );
}
