import 'package:flutter/material.dart';
import 'package:socialseed/utils/constants/page_const.dart';

// ignore: constant_identifier_names
enum MenuOptions { Edit, Copy, Delete, Report }

List<PopupMenuEntry<MenuOptions>> getPopupMenuItems() {
  return [
    PopupMenuItem<MenuOptions>(
      value: MenuOptions.Edit,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Icon(Icons.edit),
          sizeHor(10),
          const Text('Edit'),
        ],
      ),
    ),
    PopupMenuItem<MenuOptions>(
      value: MenuOptions.Delete,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Icon(Icons.delete),
          sizeHor(10),
          const Text('Delete'),
        ],
      ),
    ),
    PopupMenuItem<MenuOptions>(
      value: MenuOptions.Copy,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Icon(Icons.copy_rounded),
          sizeHor(10),
          const Text('Copy Link'),
        ],
      ),
    ),
    PopupMenuItem<MenuOptions>(
      value: MenuOptions.Report,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Icon(Icons.report),
          sizeHor(10),
          const Text('Report'),
        ],
      ),
    ),
  ];
}
