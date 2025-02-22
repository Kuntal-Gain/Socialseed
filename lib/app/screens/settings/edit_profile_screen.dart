import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socialseed/app/cubits/users/user_cubit.dart';
import 'package:socialseed/app/screens/home_screen.dart';
import 'package:socialseed/app/widgets/profile_widget.dart';
import 'package:socialseed/domain/entities/user_entity.dart';
import 'package:socialseed/utils/constants/text_const.dart';
import 'package:socialseed/utils/custom/custom_snackbar.dart';
import 'package:uuid/uuid.dart';

import '../../../utils/constants/color_const.dart';
import '../../../utils/constants/firebase_const.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.user});

  final UserEntity user;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // controllers
  late TextEditingController _nameController;
  late TextEditingController _workController;
  late TextEditingController _collegeController;
  late TextEditingController _schoolController;
  late TextEditingController _locationController;
  late TextEditingController _bioController;

  var selectedCoverImage = "";
  File? _image;

  @override
  void initState() {
    _nameController = TextEditingController(text: widget.user.fullname);
    _workController = TextEditingController(text: widget.user.work);
    _collegeController = TextEditingController(text: widget.user.college);
    _schoolController = TextEditingController(text: widget.user.school);
    _locationController = TextEditingController(text: widget.user.location);
    _bioController = TextEditingController(text: widget.user.bio);
    super.initState();
  }

  Widget getTextField(TextEditingController controller, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            label,
            style: TextConst.headingStyle(
              16,
              AppColor.blackColor,
            ),
          ),
        ),
        Container(
          height: 66,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          decoration: BoxDecoration(
            color: AppColor.greyColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: TextFormField(
            controller: controller,
            validator: (value) {
              // Add your validation logic here
              if (value!.isEmpty) {
                return 'Please enter $label';
              }

              return null;
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: label,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> uploadCoverImage(String imagePath, String uid) async {
    // Define the storage reference
    final storageRef = FirebaseStorage.instance
        .ref('/profile/$uid/cover-image/${const Uuid().v1()}.jpg');

    try {
      // Upload the image
      await storageRef.putFile(File(imagePath));

      // Get the download URL
      String downloadURL = await storageRef.getDownloadURL();

      // Update Firestore with the new cover image URL
      await FirebaseFirestore.instance
          .collection(FirebaseConst.users)
          .doc(widget.user.uid)
          .update({
        'coverImage': downloadURL,
      });

      // Optionally, show a success message
    } catch (e) {
      // Optionally, show an error message to the user
    }
  }

  Future selectImage() async {
    try {
      // Initiate image picking from the gallery
      // ignore: invalid_use_of_visible_for_testing_member
      final pickedFile = await ImagePicker.platform
          .getImageFromSource(source: ImageSource.gallery);

      setState(() {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
        } else {
          if (kDebugMode) {
            print("No image selected");
          }
        }
      });

      // If an image is selected, upload it immediately to Firebase Storage
      if (_image != null) {
        final ref = FirebaseStorage.instance.ref(
            '/profile/${widget.user.username}/profile-image/${const Uuid().v1()}.jpg');

        final uploadTask = ref.putFile(_image!);
        final imageUrl = await (await uploadTask).ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection(FirebaseConst.users)
            .doc(widget.user.uid)
            .update({
          'imageUrl': imageUrl,
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Something went wrong: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width and height for responsiveness
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: AppColor.whiteColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: screenHeight * 0.3, // 30% of the screen height
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // cover image
                        // Container(
                        //   height: screenHeight *
                        //       0.18, // Responsive height for the cover image
                        //   width: double.infinity,
                        //   margin: const EdgeInsets.all(12),
                        //   child: ClipRRect(
                        //     borderRadius: BorderRadius.circular(16),
                        //     child: Image.network(
                        //       widget.user.coverImage!,
                        //       fit: BoxFit.cover,
                        //     ),
                        //   ),
                        // ),
                        if (widget.user.coverImage != "")
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) => Dialog(
                                  backgroundColor: Colors.transparent,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Image.network(
                                          widget.user.coverImage!,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                height: screenHeight * 0.05,
                                                decoration: BoxDecoration(
                                                  color: AppColor.redColor,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    "Close",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize:
                                                          screenHeight * 0.015,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                                width:
                                                    10), // Add spacing between buttons
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () async {
                                                  // Allow current user to select a new cover image
                                                  final XFile? image =
                                                      await ImagePicker()
                                                          .pickImage(
                                                    source: ImageSource.gallery,
                                                    imageQuality: 80,
                                                  );

                                                  // ignore: use_build_context_synchronously
                                                  Navigator.of(context).pop();

                                                  if (image != null) {
                                                    setState(() {
                                                      selectedCoverImage =
                                                          image.path;
                                                    });

                                                    // Generate a unique ID
                                                    await uploadCoverImage(
                                                        image.path,
                                                        widget.user.uid!);
                                                  }
                                                },
                                                child: Container(
                                                  height: screenHeight * 0.05,
                                                  decoration: BoxDecoration(
                                                    color: AppColor.redColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "Update",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: screenHeight *
                                                            0.015,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                                width:
                                                    10), // Add spacing between buttons
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  FirebaseFirestore.instance
                                                      .collection(
                                                          FirebaseConst.users)
                                                      .doc(widget.user.uid)
                                                      .update({
                                                    "coverImage": "",
                                                  });

                                                  Navigator.of(context).pop();
                                                },
                                                child: Container(
                                                  height: screenHeight * 0.05,
                                                  decoration: BoxDecoration(
                                                    color: AppColor.redColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: const Center(
                                                    child: Text(
                                                      "Delete",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              height: 140,
                              width: double.infinity,
                              margin: const EdgeInsets.all(12),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: CachedNetworkImage(
                                  imageUrl: widget.user.coverImage!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),

                        if (widget.user.coverImage == "")
                          GestureDetector(
                            onTap: () async {
                              // Allow current user to select a new cover image
                              final XFile? image =
                                  await ImagePicker().pickImage(
                                source: ImageSource.gallery,
                                imageQuality:
                                    80, // Adjust image quality if needed
                              );

                              if (image != null) {
                                setState(() {
                                  selectedCoverImage = image.path;
                                });

                                // Generate a unique ID
                                await uploadCoverImage(
                                    image.path, widget.user.uid!);
                              }
                            },
                            child: Container(
                              height: 140,
                              width: double.infinity,
                              margin: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColor.greyColor,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Text(
                                  "No Cover Image",
                                  style: TextConst.headingStyle(
                                      16, AppColor.blackColor),
                                ),
                              ),
                            ),
                          ),
                        // profile data
                      ],
                    ),
                  ),
                  Positioned(
                    top: screenHeight *
                        0.12, // Responsive positioning of the avatar
                    // Centers the avatar based on screen width
                    left: screenWidth * 0.35,
                    child: GestureDetector(
                      onTap: selectImage,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColor.redColor,
                            width: 5,
                          ),
                        ),
                        child: CircleAvatar(
                          radius:
                              screenWidth * 0.15, // Responsive size for avatar
                          backgroundImage:
                              NetworkImage(widget.user.imageUrl.toString()),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              getTextField(_nameController, "Name"),
              getTextField(_workController, "Work"),
              getTextField(_collegeController, "College"),
              getTextField(_schoolController, "School"),
              getTextField(_locationController, "Location"),
              getTextField(_bioController, "Bio"),
              getButton("Update Profile", () {
                BlocProvider.of<UserCubit>(context).updateUser(
                    user: UserEntity(
                  uid: widget.user.uid,
                  work: _workController.text,
                  college: _collegeController.text,
                  school: _schoolController.text,
                  location: _locationController.text,
                  imageUrl: widget.user.imageUrl,
                  bio: _bioController.text,
                ));

                successBar(context, "Updated Profile Successfully");

                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (ctx) => HomeScreen(uid: widget.user.uid!),
                  ),
                );
              }, false),
              SizedBox(height: screenHeight * 0.03), // Responsive spacing
              Center(
                child: Text(
                  'Socialseed @2024 Copyright (c)',
                  style: TextConst.RegularStyle(18, AppColor.blackColor),
                ),
              ),
              SizedBox(height: screenHeight * 0.03), // Responsive spacing
            ],
          ),
        ),
      ),
    );
  }
}
