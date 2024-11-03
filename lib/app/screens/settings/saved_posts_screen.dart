import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialseed/app/cubits/savedcontent/savedcontent_cubit.dart';
import 'package:socialseed/app/screens/post/view_post_screen.dart';
import 'package:socialseed/domain/entities/user_entity.dart';
import 'package:socialseed/utils/constants/color_const.dart';
import 'package:socialseed/utils/constants/text_const.dart';
import 'package:socialseed/dependency_injection.dart' as di;

class SavedPostsScreen extends StatefulWidget {
  const SavedPostsScreen({super.key, required this.user});

  final UserEntity user;

  @override
  State<SavedPostsScreen> createState() => _SavedPostsScreenState();
}

class _SavedPostsScreenState extends State<SavedPostsScreen> {
  @override
  void initState() {
    BlocProvider.of<SavedcontentCubit>(context)
        .fetchPosts(uid: FirebaseAuth.instance.currentUser!.uid);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColor.whiteColor,
        title: Text(
          'Saved Content',
          style: TextConst.headingStyle(
            22,
            AppColor.blackColor,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios,
              color: AppColor.blackColor,
            )),
      ),
      body: BlocBuilder<SavedcontentCubit, SavedcontentState>(
        builder: (ctx, state) {
          if (state is SavedcontentLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColor.redColor,
              ),
            );
          }

          if (state is SavedcontentLoaded) {
            final posts = state.savedPosts
                .where((e) => widget.user.savedContent!.contains(e.postid))
                .toList();

            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 0,
                crossAxisSpacing: 0,
                childAspectRatio: 1,
              ),
              itemBuilder: (ctx, idx) {
                final post = posts[idx];

                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) =>
                            PostViewScreen(post: post, user: widget.user)));
                  },
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CachedNetworkImage(
                        imageUrl: post.images!.first,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
              itemCount: posts.length,
            );
          }

          return SizedBox();
        },
      ),
    );
  }
}
