import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:socialseed/app/cubits/archivepost/archivepost_cubit.dart';
import 'package:socialseed/domain/entities/user_entity.dart';

import '../../../features/services/theme_service.dart';
import '../../../utils/constants/color_const.dart';
import '../../../utils/constants/text_const.dart';
import '../post/view_post_screen.dart';

class ArchivedContentScreen extends StatefulWidget {
  const ArchivedContentScreen({super.key, required this.user});

  final UserEntity user;

  @override
  State<ArchivedContentScreen> createState() => _ArchivedContentScreenState();
}

class _ArchivedContentScreenState extends State<ArchivedContentScreen> {
  @override
  void initState() {
    BlocProvider.of<ArchivepostCubit>(context)
        .fetchPosts(uid: FirebaseAuth.instance.currentUser!.uid);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bg = Provider.of<ThemeService>(context).isDarkMode
        ? AppColor.bgDark
        : AppColor.whiteColor;

    final textColor = Provider.of<ThemeService>(context).isDarkMode
        ? AppColor.whiteColor
        : AppColor.blackColor;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        title: Text(
          'Archived Content',
          style: TextConst.headingStyle(
            22,
            textColor,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios,
              color: textColor,
            )),
      ),
      body: BlocBuilder<ArchivepostCubit, ArchivepostState>(
        builder: (ctx, state) {
          if (state is ArchivepostLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColor.redColor,
              ),
            );
          }

          if (state is ArchivepostLoaded) {
            final posts = state.archivePosts
                .where((e) => widget.user.archivedContent!.contains(e.postid))
                .toList();

            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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

          return const SizedBox();
        },
      ),
    );
  }
}
