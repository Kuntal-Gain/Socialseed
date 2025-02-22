import 'package:flutter/material.dart';
import 'package:socialseed/domain/entities/post_entity.dart';
import 'package:socialseed/domain/entities/user_entity.dart';
import 'package:socialseed/utils/constants/color_const.dart';
import 'package:socialseed/utils/constants/text_const.dart';
import 'package:video_player/video_player.dart';

class VideoPostScreen extends StatefulWidget {
  final String videoUrl;
  final PostEntity post;
  final UserEntity user;

  const VideoPostScreen(
      {Key? key,
      required this.videoUrl,
      required this.post,
      required this.user})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _VideoPostScreenState createState() => _VideoPostScreenState();
}

class _VideoPostScreenState extends State<VideoPostScreen> {
  late VideoPlayerController _videoController;
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    _videoController =
        VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
          ..initialize().then((_) {
            setState(() {});
            _videoController.play();
            _videoController.setLooping(true);
          });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isPlaying = !_isPlaying;
                _isPlaying ? _videoController.play() : _videoController.pause();
              });
            },
            child: _videoController.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _videoController.value.aspectRatio,
                    child: VideoPlayer(_videoController),
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
          // Video controls overlay
          Positioned(
            bottom: 20,
            right: 10,
            child: Column(
              children: [
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 35,
                      ),
                      onPressed: () {
                        // Handle like action
                      },
                    ),
                    Text(
                      widget.post.likes!.length.toString(),
                      style: TextConst.headingStyle(
                        16,
                        AppColor.whiteColor,
                      ),
                    )
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.comment,
                        color: Colors.white,
                        size: 35,
                      ),
                      onPressed: () {
                        // Handle comment action
                      },
                    ),
                    Text(
                      widget.post.comments!.length.toString(),
                      style: TextConst.headingStyle(
                        16,
                        AppColor.whiteColor,
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),

          Positioned(
            top: 10,
            left: 10,
            child: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 30,
                )),
          ),
        ],
      ),
    );
  }
}
