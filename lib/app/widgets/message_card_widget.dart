import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:socialseed/utils/constants/color_const.dart';
import 'package:socialseed/utils/constants/text_const.dart';

String formatTimestampTo12Hour(Timestamp timestamp) {
  // Convert Timestamp to DateTime
  DateTime dateTime = timestamp.toDate();

  // Define a DateFormat instance for the 12-hour format
  final DateFormat formatter = DateFormat('h:mm a');

  // Convert the DateTime to the desired format
  return formatter.format(dateTime);
}

Widget messageBox(bool isSender, String message, Timestamp time) {
  return Align(
    alignment: isSender ? Alignment.bottomLeft : Alignment.bottomRight,
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSender ? Colors.red : Colors.white,
        border: Border.all(color: AppColor.greyShadowColor),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomRight:
              isSender ? const Radius.circular(20) : const Radius.circular(0),
          bottomLeft:
              !isSender ? const Radius.circular(20) : const Radius.circular(0),
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 300,
          // Set a maximum width for the message box
        ),
        child: Column(
          crossAxisAlignment:
              !isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextConst.headingStyle(
                  16, isSender ? AppColor.whiteColor : AppColor.blackColor),
              softWrap: true,
              overflow: TextOverflow.clip,
            ),
            Text(formatTimestampTo12Hour(time),
                style: TextConst.MediumStyle(
                    12, isSender ? AppColor.whiteColor : AppColor.blackColor)),
          ],
        ),
      ),
    ),
  );
}
