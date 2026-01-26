import 'package:flutter/cupertino.dart';

class ScreenUtils {
  static final ScreenUtils _instance = ScreenUtils._internal();

  factory ScreenUtils() {
    return _instance;
  }

  ScreenUtils._internal();

  double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
  double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  double dynamicHeight(
    BuildContext context,
    double upperLimit,
    double lowerLimit,
  ) => (lowerLimit * screenHeight(context)) / upperLimit;
}

// sized boxs
Widget sizeHor(double width) => SizedBox(width: width);
Widget sizeVer(double height) => SizedBox(height: height);
Widget boxSize(double height, double width) =>
    SizedBox(width: width, height: height);
Widget spaceBox() => Spacer();
