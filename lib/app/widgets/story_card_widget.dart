import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:socialseed/domain/entities/story_entity.dart';
import 'package:socialseed/domain/entities/user_entity.dart';
import 'package:socialseed/utils/constants/color_const.dart';
import 'package:socialseed/utils/constants/text_const.dart';

Widget storyCard(StoryEntity story, String name, UserEntity user) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 8.0),
    width: 90, // Adjust the width according to your design
    decoration: BoxDecoration(
      image: DecorationImage(
        image: NetworkImage(story.storyData),
        fit: BoxFit.cover,
      ),
      borderRadius: BorderRadius.circular(16),
      color: Colors.grey[300],
      border: Border.all(
        color: (!story.viewers.contains(FirebaseAuth
                .instance.currentUser!.uid)) // Ensure viewers is a List<String>
            ? AppColor.redColor
            : AppColor.greyShadowColor,
        width: 5,
      ),
    ),
    child: Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          name,
          style: TextConst.MediumStyle(
            16,
            AppColor.whiteColor,
          ),
        ),
      ),
    ),
  );
}
