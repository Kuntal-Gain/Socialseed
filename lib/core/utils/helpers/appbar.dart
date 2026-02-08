import 'package:flutter/material.dart';

import '../constants/color_const.dart';

class CommonAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CommonAppbar({super.key, required this.title});
  @override
  Widget build(context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.white,
          fontSize: 18,
        ),
      ),
      backgroundColor: AppColor.redColor,
      foregroundColor: AppColor.whiteColor,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
