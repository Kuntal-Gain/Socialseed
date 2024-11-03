import 'package:flutter/material.dart';

import '../constants/color_const.dart';
import '../constants/page_const.dart';

Widget shimmerEffect() {
  return Container(
    height: 350,
    width: double.infinity,
    margin: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: AppColor.greyShadowColor,
          spreadRadius: 1,
          blurRadius: 1,
        ),
      ],
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey.withOpacity(0.2),
                    radius: 20.0,
                  ),
                  const SizedBox(width: 10.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 20,
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.2),
                            ),
                          ),
                          sizeHor(5),
                          Container(
                            height: 20,
                            width: 70,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.2),
                            ),
                          ),
                        ],
                      ),
                      sizeVar(5),
                      Container(
                        height: 20,
                        width: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            height: 20,
            margin: const EdgeInsets.all(12),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        Row(
          children: [
            sizeHor(10),

            // like

            // Like button with animation
            Container(
              height: 40,
              width: 160,
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
              ),
            ),
          ],
        )
      ],
    ),
  );
}
