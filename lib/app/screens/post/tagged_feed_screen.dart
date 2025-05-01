import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:socialseed/app/screens/post/explore_page.dart';
import 'package:socialseed/domain/entities/post_entity.dart';

import '../../../domain/entities/user_entity.dart';
import '../../../utils/constants/color_const.dart';
import '../../widgets/tag_widget.dart';
import 'view_post_screen.dart';

class TaggedFeedScreen extends StatefulWidget {
  final String tag;
  final List<PostEntity> posts;
  final UserEntity user;

  const TaggedFeedScreen(
      {super.key, required this.tag, required this.posts, required this.user});

  @override
  State<TaggedFeedScreen> createState() => _TaggedFeedScreenState();
}

class _TaggedFeedScreenState extends State<TaggedFeedScreen> {
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;

    return Scaffold(
      body: Column(
        children: [
          taggedWidgetTile(
              tag: widget.tag,
              size: mq,
              count: widget.posts.length,
              onClick: () => Navigator.pop(context)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: MasonryGridView.builder(
                gridDelegate:
                    const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // Number of columns
                ),
                itemCount: widget.posts.length,
                itemBuilder: (context, index) {
                  final image = widget.posts[index].images![0];
                  final post = widget.posts[index];

                  if (image.contains('.mp4')) {
                    return VideoTileWidget(
                      videoUrl: image,
                      post: post,
                      user: const UserEntity(),
                    );
                  }

                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PostViewScreen(
                            post: post,
                            user: widget.user,
                            posts: widget.posts,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.all(5),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: image != null && image.isNotEmpty
                            ? Image.network(image)
                            : Container(
                                height: 150,
                                color: AppColor.greyColor.withOpacity(0.3),
                                child: const Center(
                                  child: Icon(Icons.image_not_supported),
                                ),
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
