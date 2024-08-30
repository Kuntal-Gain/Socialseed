import 'package:flutter/material.dart';
import 'package:socialseed/app/screens/home_screen.dart';
import 'package:socialseed/domain/entities/story_entity.dart';
import 'package:socialseed/domain/entities/user_entity.dart';
import 'package:socialseed/utils/constants/color_const.dart';
import 'package:socialseed/utils/constants/page_const.dart';
import 'package:socialseed/utils/constants/tags_const.dart';
import 'package:socialseed/utils/constants/text_const.dart';

class StoryScreen extends StatefulWidget {
  final StoryEntity story;
  final UserEntity curruser;
  final UserEntity storyUser;
  const StoryScreen({
    super.key,
    required this.story,
    required this.curruser,
    required this.storyUser,
  });

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  List stories = [];

  @override
  void initState() {
    stories = widget.story.viewers
        .where((viewer) => viewer != widget.curruser.uid!)
        .toList();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 24, 17, 17),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              height: 80,
              width: double.infinity,
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (ctx) =>
                                HomeScreen(uid: widget.curruser.uid!)));
                      },
                      icon: const Icon(Icons.arrow_back_ios)),
                  CircleAvatar(
                    radius: 27,
                    backgroundImage: NetworkImage(widget.storyUser.imageUrl!),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.storyUser.fullname!,
                              style: TextConst.headingStyle(
                                16,
                                AppColor.whiteColor,
                              ),
                            ),
                            if (widget.storyUser.isVerified!)
                              Row(
                                children: [
                                  sizeHor(5),
                                  Image.asset(
                                    'assets/3963-verified-developer-badge-red 1.png',
                                    height: 18,
                                    width: 18,
                                  ),
                                ],
                              ),
                          ],
                        ),
                        (widget.curruser.uid! != widget.storyUser.uid)
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (widget.storyUser.work!.toLowerCase() !=
                                      "none")
                                    mutualTag("work"),
                                  if (widget.storyUser.school!.toLowerCase() !=
                                      "none")
                                    mutualTag("school"),
                                  if (widget.storyUser.college!.toLowerCase() !=
                                      "none")
                                    mutualTag("college"),
                                  if (widget.storyUser.location!
                                          .toLowerCase() !=
                                      "none")
                                    mutualTag("home"),
                                ],
                              )
                            : mutualTag("You"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Image.network(
              widget.story.storyData,
              fit: BoxFit.cover,
            ),
            Text(
              widget.story.content,
              style: TextConst.MediumStyle(
                20,
                AppColor.whiteColor,
              ),
            ),
            if (widget.story.userId == widget.curruser.uid)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(
                    Icons.remove_red_eye,
                    color: AppColor.whiteColor,
                    size: 35,
                  ),
                  Text(
                    stories.length.toString(),
                    style: TextConst.MediumStyle(
                      20,
                      AppColor.whiteColor,
                    ),
                  ),
                ],
              ),
            SizedBox(),
          ],
        ),
      ),
    );
  }
}
