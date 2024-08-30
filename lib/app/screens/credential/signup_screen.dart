// ignore_for_file: avoid_print

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:scroll_date_picker/scroll_date_picker.dart';
import 'package:socialseed/app/cubits/auth/auth_cubit.dart';
import 'package:socialseed/app/cubits/credential/credential_cubit.dart';
import 'package:socialseed/app/screens/credential/signin_screen.dart';
import 'package:socialseed/app/screens/home_screen.dart';
import 'package:socialseed/domain/entities/user_entity.dart';
import 'package:socialseed/utils/constants/color_const.dart';
import 'package:socialseed/utils/constants/page_const.dart';
import 'package:socialseed/utils/constants/text_const.dart';
// ignore: unused_import
import 'package:uuid/uuid.dart';

import '../../../utils/custom/custom_snackbar.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _workController = TextEditingController();
  final _schoolController = TextEditingController();
  final _collegeController = TextEditingController();
  final _homeController = TextEditingController();

  // local variables
  bool isPressed = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime(2000);
  bool _isSigningUp = false;
  File? _image;

  // upload

  Future selectImage() async {
    try {
      // ignore: invalid_use_of_visible_for_testing_member
      final pickedFile = await ImagePicker.platform
          .getImageFromSource(source: ImageSource.gallery);

      setState(() {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
        } else {
          print("no image");
        }
      });
    } catch (e) {
      print('something went $e');
    }
  }

  // UI Methods

  Widget getTextField(
      TextEditingController controller, String label, TextInputType key) {
    return Container(
      height: 66,
      width: double.infinity,
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColor.greyColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: key,
        validator: _validateNotEmpty,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: label,
        ),
      ),
    );
  }

  Widget getTextFieldWithCareer(
      TextEditingController controller, String label, TextInputType key) {
    return Container(
      height: 66,
      width: double.infinity,
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColor.greyColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 7,
            child: TextFormField(
              controller: controller,
              keyboardType: key,
              validator: _validateNotEmpty,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: label,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: TextButton(
                onPressed: () {
                  setState(() {
                    // CODE
                    controller.text = "NONE";
                  });
                },
                child: Text('NONE',
                    style: TextConst.headingStyle(15, AppColor.redColor))),
          )
        ],
      ),
    );
  }

  Widget getTextFieldWithPassword(
      TextEditingController controller, String label) {
    // Assuming you have this boolean in your class

    return Container(
      height: 66,
      width: double.infinity,
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColor.greyColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 7,
            child: TextFormField(
              controller: controller,
              obscureText:
                  !isPressed, // Invert the value for password visibility
              validator: _validateNotEmpty,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: label,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: IconButton(
              icon: Icon(isPressed ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                // Toggling the visibility of the password
                setState(() {
                  isPressed = !isPressed;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDatePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        // ignore: sized_box_for_whitespace
        return Container(
          height: 250, // Fixed height to avoid intrinsic dimensions error
          child: Column(
            children: [
              Expanded(
                child: ScrollDatePicker(
                  selectedDate: _selectedDate,
                  onDateTimeChanged: (value) {
                    setState(() {
                      _selectedDate = value;
                    });
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close the bottom sheet
                },
                child: const Text('SET'),
              ),
            ],
          ),
        );
      },
    );
  }

  // Example validator function for text fields
  String? _validateNotEmpty(String? value) {
    if (value == null || value.isEmpty) {
      return "This field is required";
    }
    return null;
  }

  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      if (_image == null) {
        failureBar(context, "No Image is Selected");
        setState(() {
          _isSigningUp = false; // Reset if image is not selected
        });
        return;
      } else {
        try {
          Reference ref = FirebaseStorage.instance
              .ref()
              .child('profiles')
              .child("${_nameController.text}.jpg");

          final uploadTask = ref.putFile(_image!);
          final imageUrl = await (await uploadTask).ref.getDownloadURL();

          BlocProvider.of<CredentialCubit>(context)
              .signUpUser(
            user: UserEntity(
              username: _nameController.text.split(' ').join(''),
              fullname: _nameController.text,
              email: _emailController.text,
              password: _passwordController.text,
              bio: "",
              imageUrl: imageUrl,
              friends: const [],
              milestones: const [],
              likedPages: const [],
              posts: const [],
              joinedDate: Timestamp.now(),
              isVerified: false,
              badges: const [],
              followerCount: 0,
              followingCount: 0,
              stories: const [],
              imageFile: _image,
              work: _workController.text,
              college: _collegeController.text,
              school: _schoolController.text,
              location: _homeController.text,
              coverImage: "",
              dob: Timestamp.fromDate(_selectedDate),
              followers: const [],
              following: const [],
              requests: const [],
              activeStatus: true,
            ),
          )
              .then((val) {
            // If sign up is successful, clear the text fields and reset the signing up flag
            setState(() {
              _nameController.clear();
              _emailController.clear();
              _passwordController.clear();
              _confirmPasswordController.clear();
              _isSigningUp = false;
            });
          }).catchError((error) {
            // Handle error and reset signing up flag
            setState(() {
              _isSigningUp = false;
            });
            failureBar(context, error.toString());
          });
        } catch (e) {
          setState(() {
            _isSigningUp = false;
          });
          failureBar(context, e.toString());
        }
      }
    }
  }

  _bodyWidget() {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo
            Image.asset('assets/SOCIALSEED.png'),

            // JOIN NOW
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Text(
                'Join Now',
                style: TextConst.MediumStyle(49, AppColor.blackColor),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                "Let's get started by filling out the form below.",
                style: TextConst.RegularStyle(15, AppColor.textGreyColor),
              ),
            ),

            sizeVar(15),
            // Upload Image

            GestureDetector(
              onTap: selectImage,
              child: Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  child: _image == null
                      ? Image.asset('assets/icons/user.png')
                      : null,
                ),
              ),
            ),

            sizeVar(15),
            // Form Fields
            getTextField(_nameController, 'Name', TextInputType.name),
            getTextField(_emailController, 'Email', TextInputType.emailAddress),
            getTextFieldWithPassword(_passwordController, 'Password'),
            getTextFieldWithPassword(
                _confirmPasswordController, "Confirm Password"),

            // dob

            Container(
              height: 66,
              width: double.infinity,
              margin: const EdgeInsets.all(5),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                color: AppColor.greyColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                  TextButton(
                      onPressed: () {
                        setState(() {
                          _showDatePicker(context);
                        });
                      },
                      child: Text('SET',
                          style: TextConst.headingStyle(15, AppColor.redColor)))
                ],
              ),
            ),

            getTextFieldWithCareer(_homeController, "Home", TextInputType.text),
            getTextFieldWithCareer(_workController, "work", TextInputType.text),
            getTextFieldWithCareer(
                _collegeController, "college", TextInputType.text),
            getTextFieldWithCareer(
                _schoolController, "school", TextInputType.text),

            // Submit Button
            GestureDetector(
              onTap: () {
                if (_formKey.currentState?.validate() ?? false) {
                  setState(() {
                    _isSigningUp = true;
                  });
                  _signUp();
                } else {
                  print("Form is invalid");
                }
              },
              child: Container(
                height: 66,
                width: double.infinity,
                margin: const EdgeInsets.all(10),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: _formKey.currentState?.validate() ?? false
                      ? AppColor.redColor
                      : AppColor.whiteColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xffc2c2c2),
                  ),
                ),
                child: Center(
                  child: !_isSigningUp
                      ? Text(
                          "Create Account",
                          style: TextConst.headingStyle(
                              18,
                              _formKey.currentState?.validate() ?? false
                                  ? AppColor.whiteColor
                                  : AppColor.redColor),
                        )
                      : const CircularProgressIndicator(
                          color: Colors.white,
                        ),
                ),
              ),
            ),

            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 14.0),
                  child: Text(
                    'Do You Have an Account?',
                    style: TextConst.RegularStyle(15, AppColor.textGreyColor),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (ctx) => const SignInScreen()));
                  },
                  child: Text('Login',
                      style: TextConst.headingStyle(15, AppColor.redColor)),
                )
              ],
            ),
            sizeVar(30),
            Center(
              child: Text(
                'Socialseed @2024 Copyright (c)',
                style: TextConst.RegularStyle(18, AppColor.blackColor),
              ),
            ),
            sizeVar(30),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      body: BlocConsumer<CredentialCubit, CredentialState>(
        listener: (context, state) {
          if (state is CredentialSuccess) {
            BlocProvider.of<AuthCubit>(context).loggedIn();
          }

          if (state is CredentialFailure) {
            failureBar(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is CredentialSuccess) {
            return BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                if (state is Authenticated) {
                  return HomeScreen(uid: state.uid);
                } else {
                  return _bodyWidget();
                }
              },
            );
          }

          return _bodyWidget();
        },
      ),
    );
  }
}
