// Nececcessy Dependencies
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_dropdown/cool_dropdown.dart';
import 'package:cool_dropdown/models/cool_dropdown_item.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

// Useful Imports
import 'package:socialseed/app/cubits/post/post_cubit.dart';
import 'package:socialseed/app/screens/home_screen.dart';
import 'package:socialseed/app/screens/post/location_screen.dart';
import 'package:socialseed/app/widgets/post_widget.dart';
import 'package:socialseed/domain/entities/post_entity.dart';
import 'package:socialseed/domain/entities/user_entity.dart';

class PostScreen extends StatefulWidget {
  final UserEntity currentUser;

  const PostScreen({Key? key, required this.currentUser}) : super(key: key);

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  // Varibles
  final TextEditingController _captionController = TextEditingController();
  List<File?> images = [];
  List<String> tags = ['a', 'b'];
  String location = "";
  String type = 'public';
  String user = 'Devika';
  List<String?> imageFiles = [];

  // Cloud Storage
  FirebaseStorage storage = FirebaseStorage.instance;

  // Useful Methods
  Future<void> uploadPost(PostEntity post) async {
    for (int i = 0; i < images.length; i++) {
      File? image = images[i];

      if (image != null) {
        Reference ref = storage
            .ref()
            .child('Posts')
            .child('${post.username}/${post.postid}$i.jpg');

        final uploadTask = ref.putFile(image);

        final imageUrl = await (await uploadTask).ref.getDownloadURL();

        imageFiles.add(imageUrl);
      }
    }

    // ignore: use_build_context_synchronously
    BlocProvider.of<PostCubit>(context)
        .createPost(
            post: PostEntity(
      postid: post.postid,
      profileId: widget.currentUser.imageUrl,
      uid: widget.currentUser.uid,
      username: widget.currentUser.username,
      postType: type,
      content: _captionController.text,
      images: imageFiles,
      likes: const [],
      comments: const [],
      shares: 0,
      location: location,
      tags: const [],
      creationDate: Timestamp.now(),
      isVerified: widget.currentUser.isVerified,
    ))
        .then((value) {
      setState(() {
        _captionController.clear();
      });
    });
  }

  Future<void> addImage() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      setState(() {
        if (pickedFile != null) {
          images.add(File(pickedFile.path));
        } else {
          if (kDebugMode) {
            print('No Image Selected');
          }
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Something Went wrong: $e');
      }
    }
  }

  // Controller Disposal
  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Create Post'),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () {
              uploadPost(
                PostEntity(
                  username: widget.currentUser.username,
                  images: images,
                  postid: const Uuid().v4(),
                ),
              );

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
                  'Next',
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
                                if (tags.isNotEmpty) getTagUsers(tags),
                                const SizedBox(width: 10),
                                if (location.isNotEmpty) getLocation(location),
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
                          hintText: "What's on your mind?",
                          border: InputBorder.none,
                          hintStyle: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    if (images.length == 1)
                      Container(
                        margin: const EdgeInsets.all(12),
                        height: 250,
                        width: double.infinity,
                        decoration: const BoxDecoration(),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            images[0]!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    if (images.length == 2)
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.all(12),
                              height: 250,
                              decoration: const BoxDecoration(),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.file(
                                  images[0]!,
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
                                child: Image.file(
                                  images[1]!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (images.length == 3)
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
                                    child: Image.file(
                                      images[0]!,
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
                                    child: Image.file(
                                      images[1]!,
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
                              child: Image.file(
                                images[2]!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (images.length == 4)
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
                                    child: Image.file(
                                      images[0]!,
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
                                    child: Image.file(
                                      images[1]!,
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
                                    child: Image.file(
                                      images[2]!,
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
                                    child: Image.file(
                                      images[3]!,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    if (images.length >= 5)
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
                                    child: Image.file(
                                      images[0]!,
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
                                    child: Image.file(
                                      images[1]!,
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
                                    child: Image.file(
                                      images[2]!,
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
                                        child: Image.file(
                                          images[3]!,
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

            // options
            Column(
              children: [
                const Divider(
                  height: 5.0,
                  color: Colors.black,
                ),
                Center(
                  child: TextButton.icon(
                    onPressed: addImage,
                    icon: const Icon(
                      Icons.image_outlined,
                      color: Color.fromRGBO(255, 49, 49, 1),
                    ),
                    label: const Text(
                      "Photo/Video",
                      style: TextStyle(
                          color: Color.fromRGBO(255, 49, 49, 1),
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const Divider(
                  height: 5.0,
                  color: Colors.black,
                ),
                Center(
                  child: TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.person_2,
                      color: Color.fromRGBO(255, 49, 49, 1),
                    ),
                    label: const Text(
                      "Tag People",
                      style: TextStyle(
                          color: Color.fromRGBO(255, 49, 49, 1),
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const Divider(
                  height: 5.0,
                  color: Colors.black,
                ),
                Center(
                  child: TextButton.icon(
                    onPressed: () async {
                      final result = await Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (ctx) => const LocationScreen()));

                      setState(() {
                        location = result;
                      });
                    },
                    icon: const Icon(
                      Icons.location_on,
                      color: Color.fromRGBO(255, 49, 49, 1),
                    ),
                    label: const Text(
                      "Location",
                      style: TextStyle(
                          color: Color.fromRGBO(255, 49, 49, 1),
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
