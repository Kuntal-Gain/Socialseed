// Nececcessy Dependencies
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cool_dropdown/cool_dropdown.dart';
import 'package:cool_dropdown/models/cool_dropdown_item.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Useful Imports
import 'package:socialseed/app/cubits/post/post_cubit.dart';
import 'package:socialseed/app/screens/home_screen.dart';
import 'package:socialseed/app/widgets/post_widget.dart';
import 'package:socialseed/domain/entities/post_entity.dart';
import 'package:socialseed/domain/entities/user_entity.dart';

import '../../../features/services/theme_service.dart';
import '../../../utils/constants/color_const.dart';

class EditPostScreen extends StatefulWidget {
  final UserEntity currentUser;
  final PostEntity post;

  const EditPostScreen(
      {Key? key, required this.currentUser, required this.post})
      : super(key: key);

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  // Varibles
  late TextEditingController _captionController;
  List<File?> images = [];
  List<UserEntity> tags = [];
  String location = "";
  String type = 'public';
  String user = 'Devika';
  List<String?> imageFiles = [];

  @override
  void initState() {
    super.initState();

    _captionController = TextEditingController(text: widget.post.content);
  }

  // Cloud Storage
  FirebaseStorage storage = FirebaseStorage.instance;

  // Useful Methods
  Future<void> updatePost() async {
    // ignore: use_build_context_synchronously
    BlocProvider.of<PostCubit>(context)
        .updatePost(
            post: PostEntity(
      postid: widget.post.postid,
      content: _captionController.text,
    ))
        .then((value) {
      setState(() {
        _captionController.clear();
      });
    });
  }

  // Controller Disposal
  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Provider.of<ThemeService>(context).isDarkMode
        ? AppColor.whiteColor
        : AppColor.blackColor;

    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColor.whiteColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Edit Post'),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () {
              updatePost();

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => HomeScreen(
                    uid: widget.currentUser.uid.toString(),
                  ),
                ),
              );
            },
            child: Container(
              height: 35,
              width: 75,
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'Update',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // appbar

            // Post
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 10,
                            right: 10,
                            top: 10,
                            bottom: 20,
                          ),
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(
                                widget.currentUser.imageUrl.toString()),
                            radius: 30,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  widget.currentUser.username.toString(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (widget.post.tags!.isNotEmpty)
                                  getTagUsers(tags),
                                const SizedBox(width: 10),
                                if (widget.post.location!.isNotEmpty)
                                  getLocation(location, textColor),
                              ],
                            ),
                            SizedBox(
                              width: 100,
                              child: CoolDropdown(
                                defaultItem:
                                    CoolDropdownItem(label: 'Public', value: 1),
                                dropdownList: [
                                  CoolDropdownItem(label: 'Public', value: 1),
                                  CoolDropdownItem(label: 'Private', value: 2),
                                ],
                                controller: DropdownController(),
                                onChange: (value) {
                                  type = (value == 2) ? "Private" : "Public";
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: TextField(
                        controller: _captionController,
                        maxLines: null,
                        decoration: const InputDecoration(
                          hintText: "( Updated Caption )",
                          border: InputBorder.none,
                          hintStyle: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    if (widget.post.images!.length == 1)
                      Container(
                        margin: const EdgeInsets.all(12),
                        height: 250,
                        width: double.infinity,
                        decoration: const BoxDecoration(),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: CachedNetworkImage(
                            imageUrl: widget.post.images![0],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    if (widget.post.images!.length == 2)
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.all(12),
                              height: 250,
                              decoration: const BoxDecoration(),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: CachedNetworkImage(
                                  imageUrl: widget.post.images![0],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.all(12),
                              height: 250,
                              decoration: const BoxDecoration(),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: CachedNetworkImage(
                                  imageUrl: widget.post.images![1],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (widget.post.images!.length == 3)
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.all(12),
                                  height: 125,
                                  decoration: const BoxDecoration(),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: CachedNetworkImage(
                                      imageUrl: widget.post.images![0],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.all(12),
                                  height: 125,
                                  decoration: const BoxDecoration(),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: CachedNetworkImage(
                                      imageUrl: widget.post.images![1],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            margin: const EdgeInsets.all(12),
                            height: 125,
                            width: double.infinity,
                            decoration: const BoxDecoration(),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: CachedNetworkImage(
                                imageUrl: widget.post.images![2],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (widget.post.images!.length == 4)
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.all(12),
                                  height: 125,
                                  decoration: const BoxDecoration(),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: CachedNetworkImage(
                                      imageUrl: widget.post.images![0],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.all(12),
                                  height: 125,
                                  decoration: const BoxDecoration(),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: CachedNetworkImage(
                                      imageUrl: widget.post.images![1],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.all(12),
                                  height: 125,
                                  decoration: const BoxDecoration(),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: CachedNetworkImage(
                                      imageUrl: widget.post.images![2],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.all(12),
                                  height: 125,
                                  decoration: const BoxDecoration(),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: CachedNetworkImage(
                                      imageUrl: widget.post.images![3],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    if (widget.post.images!.length >= 5)
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.all(12),
                                  height: 125,
                                  decoration: const BoxDecoration(),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: CachedNetworkImage(
                                      imageUrl: widget.post.images![0],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.all(12),
                                  height: 125,
                                  decoration: const BoxDecoration(),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: CachedNetworkImage(
                                      imageUrl: widget.post.images![1],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.all(12),
                                  height: 125,
                                  decoration: const BoxDecoration(),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: CachedNetworkImage(
                                      imageUrl: widget.post.images![2],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.all(6),
                                  height: 125,
                                  decoration: const BoxDecoration(),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: CachedNetworkImage(
                                          imageUrl: widget.post.images![3],
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Container(
                                        color: Colors.black.withOpacity(
                                            0.5), // Adjust opacity as needed
                                        child: Center(
                                          child: Text(
                                            "${images.length - 3}+",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
