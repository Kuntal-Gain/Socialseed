import 'package:flutter/material.dart';
import 'package:socialseed/domain/entities/user_entity.dart';

import '../../../utils/constants/color_const.dart';

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

  @override
  void initState() {
    _nameController = TextEditingController(text: widget.user.fullname);
    _workController = TextEditingController(text: widget.user.work);
    _collegeController = TextEditingController(text: widget.user.college);
    _schoolController = TextEditingController(text: widget.user.school);
    _locationController = TextEditingController(text: widget.user.location);
    super.initState();
  }

  Widget getTextField(TextEditingController controller, String label) {
    return Container(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: 250,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // cover image
                        Container(
                          height: 140,
                          width: double.infinity,
                          margin: const EdgeInsets.all(12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              'assets/post-2.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // profile data
                      ],
                    ),
                  ),
                  Positioned(
                    top: 90,
                    left: 135,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColor.redColor,
                          width: 5,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 55,
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
            ],
          ),
        ),
      ),
    );
  }
}
