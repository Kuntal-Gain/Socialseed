import 'package:flutter/material.dart';
import 'package:socialseed/core/utils/helpers/no_data_found_widget.dart';

Widget errorWidget(Object errorMsg, StackTrace st, {VoidCallback? onRefresh}) {
  print("Error : $errorMsg");
  print("Stack : $st");
  return NoDataFoundWidget(
    title: 'Something Went Wrong',
    message: errorMsg.toString(),
    icon: Icons.warning,
    onRefresh: onRefresh,
  );
}
