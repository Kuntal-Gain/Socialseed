// ignore_for_file: use_build_context_synchronously, duplicate_ignore

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socialseed/app/cubits/story/story_cubit.dart';
import 'package:socialseed/domain/entities/story_entity.dart';
import 'package:socialseed/domain/entities/user_entity.dart';
import 'package:socialseed/utils/constants/asset_const.dart';
import 'package:socialseed/utils/constants/color_const.dart';
import 'package:socialseed/utils/constants/text_const.dart';
import 'package:socialseed/utils/custom/custom_snackbar.dart';
import 'package:uuid/uuid.dart';

class PostStory extends StatefulWidget {
  final UserEntity user;
  const PostStory({super.key, required this.user});

  @override
  State<PostStory> createState() => _PostStoryState();
}

class _PostStoryState extends State<PostStory> {
  File? _imageFile;
  final TextEditingController _captionController = TextEditingController();
  bool isPressed = false;
  final storyId = const Uuid().v4();

  Future<void> _showImageSourceDialog() async {
    await Future.delayed(Duration.zero);
    showDialog(
      // ignore: use_build_context_synchronously
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: SizedBox(
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => _pickImage(ImageSource.camera),
                  child: Container(
                    padding: const EdgeInsets.all(25),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera),
                        Text('Camera'),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _pickImage(ImageSource.gallery),
                  child: Container(
                    padding: const EdgeInsets.all(25),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.photo),
                        Text('Gallery'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        // Convert picked file to Uint8List for cropping
        final imageBytes = await File(pickedFile.path).readAsBytes();

        // Show image cropper
        final Uint8List? editedImage = await Navigator.push(
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
            _imageFile = tempFile;
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

    // ignore: use_build_context_synchronously
    Navigator.of(context).pop();
  }

  Future<String> uploadFile(File file, String storyId) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('stories/${widget.user.username}/$storyId');
      final uploadTask = await storageRef.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      rethrow;
    }
  }

  @override
  void initState() {
    super.initState();
    _showImageSourceDialog();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 39, 38, 38),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColor.whiteColor,
          ),
        ),
        title: Text(
          'Post Story',
          style: TextConst.MediumStyle(
            18,
            AppColor.whiteColor,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 39, 38, 38),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(),
              if (_imageFile == null) ...[
                const Center(
                  child: Text(
                    'No image selected',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ] else ...[
                Image.file(
                  _imageFile!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(14),
              width: 200,
              decoration: BoxDecoration(
                color: AppColor.whiteColor,
                border: Border.all(
                  color: AppColor.redColor,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.shade300,
                    blurRadius: 2,
                    spreadRadius: 1,
                  )
                ],
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(13.0),
                child: TextField(
                  maxLines: null,
                  controller: _captionController,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    hintText: 'Caption',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColor.redColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: IconButton(
                onPressed: () async {
                  // Show the uploading snackbar
                  updateBar(context, "Uploading");

                  final asset = await uploadFile(_imageFile!, storyId);

                  // ignore: use_build_context_synchronously
                  BlocProvider.of<StoryCubit>(context)
                      .createStory(
                          story: StoryEntity(
                              id: storyId,
                              userId: widget.user.uid!,
                              storyData: asset,
                              createdAt: Timestamp.now(),
                              content: _captionController.text,
                              expiresAt: Timestamp.fromDate(
                                DateTime.now().add(const Duration(hours: 24)),
                              ),
                              viewers: const []),
                          context: context)
                      .then((value) {
                    Navigator.pop(context);
                    successBar(context, "Story Uploaded Successfully...");
                  });
                },
                icon: Image.asset(
                  IconConst.shareIcon,
                  height: 35,
                  width: 35,
                ),
              ),
            ),
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
