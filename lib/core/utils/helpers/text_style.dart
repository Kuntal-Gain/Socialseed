import 'package:flutter/material.dart';

TextStyle appTextStyle({
  double fontSize = 16,
  FontWeight fontWeight = FontWeight.normal,
  Color color = Colors.black,
  TextDecoration textDecoration = TextDecoration.none,
}) {
  return TextStyle(
    fontFamily: 'Fira Sans',
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    decoration: textDecoration,
  );
}
