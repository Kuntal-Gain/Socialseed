import 'package:flutter/material.dart';

Widget postItem(String iconId, num? value) {
  return Row(
    children: [
      Container(
        height: 25,
        width: 25,
        margin: const EdgeInsets.all(12),
        child: Image.asset(iconId),
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
