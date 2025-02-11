// Nececcessy Dependencies
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_dropdown/cool_dropdown.dart';
import 'package:cool_dropdown/models/cool_dropdown_item.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:socialseed/app/screens/post/tags_screen.dart';
import 'package:socialseed/app/widgets/image_card.dart';
import 'package:socialseed/app/widgets/video_card.dart';
import 'package:socialseed/utils/constants/color_const.dart';
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
import 'package:video_player/video_player.dart';

import '../../../features/api/generate_caption.dart';
import '../../../utils/custom/custom_snackbar.dart';

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
  List<File?> videos = [];
  List<UserEntity> tags = [];
  String location = "";
  String type = 'public';
  String user = 'Devika';
  List<String?> imageFiles = [];
  List<String?> videoFiles = [];
  List<String> topics = [];
  bool isAI = false;
  List<VideoPlayerController> _controllers = [];

  List<String> splitTopics(String data) {
    // Split the string by commas and trim whitespace from each topic
    List<String> splitData =
        data.split(',').map((topic) => topic.trim()).toList();

    // Filter out any empty strings
    return splitData.where((topic) => topic.isNotEmpty).toList();
  }

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
            .child('${post.username}/${post.postid}-$i.jpg');

        final uploadTask = ref.putFile(image);

        final imageUrl = await (await uploadTask).ref.getDownloadURL();

        imageFiles.add(imageUrl);
      }
    }

    for (int i = 0; i < videos.length; i++) {
      File? video = videos[i];

      if (video != null) {
        Reference ref = storage
            .ref()
            .child('Posts')
            .child('${post.username}/${post.postid}-video$i.mp4');

        final uploadTask = ref.putFile(video);

        final videoUrl = await (await uploadTask).ref.getDownloadURL();

        videoFiles.add(videoUrl);
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
        images: [...imageFiles, ...videoFiles],
        likes: const [],
        likedUsers: const [],
        comments: const [],
        shares: 0,
        location: location,
        tags: const [],
        creationDate: Timestamp.now(),
        isVerified: widget.currentUser.isVerified,
        work: widget.currentUser.work,
        school: widget.currentUser.school,
        college: widget.currentUser.college,
        home: widget.currentUser.location,
      ),
    )
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

      if (pickedFile != null) {
        // Convert picked file to Uint8List for cropping
        final imageBytes = await File(pickedFile.path).readAsBytes();

        // Show image cropper
        final Uint8List? editedImage = await Navigator.push(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
            builder: (context) => ImageEditor(
              image: imageBytes,
            ),
          ),
        );

        if (editedImage != null) {
          // Create a temporary file to store the edited image
          final tempDir = await Directory.systemTemp.createTemp();
          final tempFile = File('${tempDir.path}/edited_image.jpg');
          await tempFile.writeAsBytes(editedImage);

          setState(() {
            images.add(tempFile);
          });
        }
      } else {
        if (kDebugMode) {
          print('No Image Selected');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Something Went wrong: $e');
      }
    }
  }

  Future<void> _pickVideo() async {
    final pickedFile =
        await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      File videoFile = File(pickedFile.path);
      VideoPlayerController controller = VideoPlayerController.file(videoFile)
        ..initialize().then((_) {
          setState(() {}); // Refresh UI when the video is ready
        });

      setState(() {
        videos.add(videoFile);
        _controllers.add(controller);
      });
    }
  }

  // Controller Disposal
  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose(); // Dispose of all controllers
    }
    _captionController.dispose();
    super.dispose();
  }

  void addTag(UserEntity user) {
    setState(() {
      tags.add(user);
    });
  }

  @override
  void initState() {
    getCaption('');
    super.initState();
  }

  void getCaption(String data) async {
    if (data.isNotEmpty && data != "Loading...") {
      try {
        final caption = await PostService().generateCaption(splitTopics(data));
        if (mounted) {
          setState(() {
            if (_captionController.text == "Loading..." ||
                _captionController.text.isEmpty) {
              _captionController.text = caption;
            }
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _captionController.text = ''; // Clear text if there's an error
          });
        }
        if (kDebugMode) {
          print('Error generating caption: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColor.whiteColor,
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
                              height: 40,
                              child: CoolDropdown(
                                defaultItem: CoolDropdownItem(
                                  label: 'Public',
                                  value: 1,
                                ),
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
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _captionController,
                              maxLines: null,
                              decoration: InputDecoration(
                                hintText: !isAI
                                    ? "What's on your mind?"
                                    : "Write few topic names eg. Nature , Environment , Urban",
                                border: InputBorder.none,
                                hintStyle: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              if (!isAI) {
                                setState(() {
                                  isAI = true;
                                  _captionController.clear();
                                });
                              } else {
                                final currentText = _captionController.text;
                                if (currentText.isNotEmpty &&
                                    currentText != "Loading...") {
                                  _captionController.text = "Loading...";
                                  getCaption(currentText);
                                  setState(() {
                                    isAI = false;
                                  });
                                }
                              }
                            },
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: Image.network(
                                'https://cdn-icons-png.flaticon.com/512/17653/17653338.png',
                                fit: BoxFit.contain,
                                color: isAI
                                    ? AppColor.redColor
                                    : AppColor.blackColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (videos.isNotEmpty && images.isEmpty) ...[
                      if (videos.length == 1) videoCard1(_controllers[0]),
                      if (videos.length == 2) videoCard2(_controllers),
                      if (videos.length == 3) videoCard3(_controllers),
                    ],
                    if (images.isNotEmpty && videos.isEmpty) ...[
                      if (images.length == 1) imageCard1(images[0]!),
                      if (images.length == 2) imageCard2(images),
                      if (images.length == 3) imageCard3(images),
                      if (images.length == 4) imageCard4(images),
                      if (images.length >= 5) imageCardN(images),
                    ],
                    if (videos.isEmpty && images.isEmpty)
                      Container(
                        height: 150,
                        alignment: Alignment.center,
                        child: Text(
                          "No media available",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
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
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                            height: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(14),
                                topRight: Radius.circular(14),
                              ),
                              color: Colors.white,
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: const Icon(
                                    Icons.camera_alt,
                                    color: Color.fromRGBO(255, 49, 49, 1),
                                  ),
                                  title: const Text(
                                    'Photo',
                                    style: TextStyle(
                                      color: Color.fromRGBO(255, 49, 49, 1),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                    if (videos.isEmpty)
                                      addImage();
                                    else if (videos.isNotEmpty)
                                      failureBar(
                                        context,
                                        "Images cannot be Added Here.",
                                      );
                                  },
                                ),
                                const Divider(height: 1),
                                ListTile(
                                  leading: const Icon(
                                    Icons.videocam,
                                    color: Color.fromRGBO(255, 49, 49, 1),
                                  ),
                                  title: const Text(
                                    'Video',
                                    style: TextStyle(
                                      color: Color.fromRGBO(255, 49, 49, 1),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);

                                    if (images.isEmpty)
                                      _pickVideo();
                                    else if (images.isNotEmpty)
                                      failureBar(context,
                                          "Videos cannot be Added Here.");
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    icon: const Icon(
                      Icons.image_outlined,
                      color: Color.fromRGBO(255, 49, 49, 1),
                    ),
                    label: const Text(
                      "Photo/Video",
                      style: TextStyle(
                        color: Color.fromRGBO(255, 49, 49, 1),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
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
                      final res = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => TagPeopleScreen(
                            currentUid: widget.currentUser.uid!,
                            onUserSelected: (addTag),
                          ),
                        ),
                      );

                      setState(() {
                        tags.add(res);
                      });
                    },
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
