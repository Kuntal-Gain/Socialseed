import 'package:flutter/material.dart';
import 'package:socialseed/app/widgets/view_post_widget.dart';
import 'package:socialseed/domain/entities/comment_entity.dart';

import '../../utils/constants/page_const.dart';

Widget commentCard(CommentEntity comment) {
  String caption = comment.content.toString();

  double size = 80;
  int totalLines = (caption.length / 35).ceil();

  size = size + totalLines * 35;

  return Container(
    height: size,
    width: double.infinity,
    margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      border: Border.all(color: const Color(0xffc2c2c2)),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(comment.profileUrl.toString()),
              radius: 25.0,
            ),
            sizeHor(10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      comment.username.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    sizeHor(5),
                    Image.asset(
                      'assets/3963-verified-developer-badge-red 1.png',
                      height: 18,
                      width: 18,
                    ),
                    sizeHor(20),
                  ],
                ),
                Text(comment.content.toString()),
              ],
            ),
          ],
        ),
        Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(getTime(comment.createAt)),
            )),
      ],
    ),
  );
}
