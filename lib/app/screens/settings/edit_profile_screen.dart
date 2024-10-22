import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialseed/app/cubits/users/user_cubit.dart';
import 'package:socialseed/app/screens/home_screen.dart';
import 'package:socialseed/app/widgets/profile_widget.dart';
import 'package:socialseed/domain/entities/user_entity.dart';
import 'package:socialseed/utils/constants/text_const.dart';
import 'package:socialseed/utils/custom/custom_snackbar.dart';

import '../../../utils/constants/color_const.dart';
import '../../../utils/constants/page_const.dart';

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

  @override
  Widget build(BuildContext context) {
    // Get screen width and height for responsiveness
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(),
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
                        Container(
                          height: screenHeight *
                              0.18, // Responsive height for the cover image
                          width: double.infinity,
                          margin: const EdgeInsets.all(12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              widget.user.coverImage!,
                              fit: BoxFit.cover,
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
                    left: screenWidth *
                        0.4, // Centers the avatar based on screen width
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
