import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../utils/constants/color_const.dart';

Widget videoCard1(VideoPlayerController controller) {
  return Container(
    margin: const EdgeInsets.all(12),
    height: 250,
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.grey.shade300,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: VideoPlayer(controller),
        ),
        Align(
          alignment: Alignment.center,
          child: Icon(
            Icons.play_arrow,
            color: Colors.white,
            size: 35,
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Icon(
            Icons.play_circle_fill,
            color: AppColor.redColor,
            size: 50,
          ),
        )
      ],
    ),
  );
}

Widget videoCard2(List<VideoPlayerController> controllers) {
  return Row(
    children: [
      Expanded(
        child: Container(
          margin: const EdgeInsets.all(12),
          height: 250,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: VideoPlayer(controllers[0]),
              ),
              Align(
                alignment: Alignment.center,
                child: Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 35,
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Icon(
                  Icons.play_circle_fill,
                  color: AppColor.redColor,
                  size: 50,
                ),
              )
            ],
          ),
        ),
      ),
      Expanded(
        child: Container(
          margin: const EdgeInsets.all(12),
          height: 250,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: VideoPlayer(controllers[1]),
              ),
              Align(
                alignment: Alignment.center,
                child: Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 35,
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Icon(
                  Icons.play_circle_fill,
                  color: AppColor.redColor,
                  size: 50,
                ),
              )
            ],
          ),
        ),
      ),
    ],
  );
}

Widget videoCard3(List<VideoPlayerController> controllers) {
  return Column(
    children: [
      Row(
        children: [
          Expanded(
            child: _buildVideoContainer(controllers[0]),
          ),
          Expanded(
            child: _buildVideoContainer(controllers[1]),
          ),
        ],
      ),
      _buildVideoContainer(controllers[2]),
    ],
  );
}

Widget _buildVideoContainer(VideoPlayerController controller) {
  return Container(
    margin: const EdgeInsets.all(12),
    height: 125,
    decoration: BoxDecoration(
      color: Colors.grey.shade300,
      borderRadius: BorderRadius.circular(14),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: AspectRatio(
              aspectRatio:
                  controller.value.aspectRatio, // Maintain video aspect ratio
              child: VideoPlayer(controller),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Icon(
              Icons.play_circle_fill,
              color: AppColor.redColor,
              size: 50,
            ),
          ),
        ],
      ),
    ),
  );
}
