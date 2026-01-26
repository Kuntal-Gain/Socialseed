import 'package:flutter/material.dart';
import 'package:socialseed/core/utils/constants/color_const.dart';
import 'package:socialseed/core/utils/helpers/screen_utils.dart';
import 'package:socialseed/core/utils/helpers/scroll_view.dart';
import 'package:socialseed/features/feed/ui/widget/post_widget.dart';
import 'package:socialseed/features/feed/ui/widget/story_widget.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColor.whiteColor,
        body: CommonScreenWrapper(
            containsScrollable: true,
            body: SafeArea(
              child: Column(
                children: [
                  _buildLogo(),
                  sizeVer(10),
                  _buildSearchbar(),
                  sizeVer(10),
                  _buildStoryList(),
                  _buildPostList(),
                ],
              ),
            )));
  }

  // widgets

  Widget _buildStoryList() {
    final double cardHeight = ScreenUtils().screenHeight(context) * 0.12;

    return SizedBox(
      height: cardHeight + 24, // enough space for +
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return StoryCard(isAddStory: index == 0);
        },
      ),
    );
  }

  Widget _buildPostList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) {
        return PostWidget(isImage: index % 2 == 0);
      },
    );
  }

  Widget _buildSearchbar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              style: const TextStyle(fontSize: 15),
              decoration: const InputDecoration(
                hintText: "Search users...",
                border: InputBorder.none,
                isCollapsed: true,
              ),
              onChanged: (value) {
                // TODO: Trigger search logic
                // e.g. ref.read(searchProvider.notifier).search(value);
              },
            ),
          ),
          const Icon(Icons.tune_rounded, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: Image.asset(
          'assets/images/logo.png',
          height: ScreenUtils().screenHeight(context) * 0.065,
        ),
      ),
    );
  }
}
