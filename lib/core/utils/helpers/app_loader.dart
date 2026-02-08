import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:socialseed/core/utils/constants/color_const.dart';

class AppLoader {
  Widget loaderWidget() => Center(
        child: CircularProgressIndicator(
          color: AppColor.redColor,
        ),
      );

  Widget stateLoader() => Center(
        child: CupertinoActivityIndicator(
          color: AppColor.redColor,
        ),
      );
}
