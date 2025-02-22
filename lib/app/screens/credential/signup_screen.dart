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
import 'package:socialseed/app/widgets/profile_widget.dart';
import 'package:socialseed/domain/entities/user_entity.dart';
import 'package:socialseed/utils/constants/color_const.dart';
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
  final _usernameController = TextEditingController();
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
                    style: TextConst.headingStyle(12, AppColor.redColor))),
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
          height: 250,
          color: AppColor
              .whiteColor, // Fixed height to avoid intrinsic dimensions error
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
              getButton("SET", () => Navigator.pop(context), false),
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
      try {
        String imageUrl =
            "https://img.freepik.com/free-vector/flat-style-woman-avatar_90220-2876.jpg?t=st=1738591624~exp=1738595224~hmac=52da34b292612a1adee327b033aead6f06df21e591cb425cb1ed0acfd2fdfcfa&w=740"; // Replace with your actual default image URL

        if (_image != null) {
          Reference ref = FirebaseStorage.instance
              .ref()
              .child('profiles')
              .child("${_nameController.text}.jpg");

          final uploadTask = ref.putFile(_image!);
          imageUrl = await (await uploadTask).ref.getDownloadURL();
        }

        // ignore: use_build_context_synchronously
        BlocProvider.of<CredentialCubit>(context)
            .signUpUser(
          user: UserEntity(
            username: _usernameController.text,
            fullname: _nameController.text,
            email: _emailController.text,
            password: _passwordController.text,
            bio: "",
            imageUrl: imageUrl, // Uses uploaded image or default one
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
            work: _workController.text.isEmpty ? "None" : _workController.text,
            college: _collegeController.text.isEmpty
                ? "None"
                : _collegeController.text,
            school: _schoolController.text.isEmpty
                ? "None"
                : _schoolController.text,
            location:
                _homeController.text.isEmpty ? "None" : _homeController.text,
            coverImage: "",
            dob: Timestamp.fromDate(_selectedDate),
            followers: const [],
            following: const [],
            requests: const [],
            activeStatus: true,
          ),
        )
            .then((val) {
          // Clear fields after successful signup
          setState(() {
            _nameController.clear();
            _emailController.clear();
            _passwordController.clear();
            _confirmPasswordController.clear();
            _isSigningUp = false;
          });
        }).catchError((error) {
          setState(() {
            _isSigningUp = false;
          });
          // ignore: use_build_context_synchronously
          failureBar(context, error.toString());
        });
      } catch (e) {
        setState(() {
          _isSigningUp = false;
        });
        // ignore: use_build_context_synchronously
        failureBar(context, e.toString());
      }
    }
  }

  // Body Widget
  Widget _bodyWidget() {
    final screenWidth = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05, // Adjust padding with MediaQuery
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset('assets/SOCIALSEED.png'),
              const SizedBox(height: 20),
              Text(
                'Join Now',
                style: TextConst.MediumStyle(
                  screenWidth * 0.1, // Adjust text size with MediaQuery
                  AppColor.blackColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Let's get started by filling out the form below.",
                style: TextConst.RegularStyle(15, AppColor.textGreyColor),
              ),
              const SizedBox(height: 15),
              GestureDetector(
                onTap: selectImage,
                child: Center(
                  child: CircleAvatar(
                    radius:
                        screenWidth * 0.15, // Adjust image size with MediaQuery
                    backgroundColor: Colors.white,
                    backgroundImage: _image != null ? FileImage(_image!) : null,
                    child: _image == null
                        ? Image.asset(
                            'assets/icons/user.png',
                            color: const Color(0xffc2c2c2),
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              getTextField(_usernameController, 'Username', TextInputType.name),
              getTextField(_nameController, 'Name', TextInputType.name),
              getTextField(
                  _emailController, 'Email', TextInputType.emailAddress),
              getTextFieldWithPassword(_passwordController, 'Password'),
              getTextFieldWithPassword(
                  _confirmPasswordController, "Confirm Password"),
              Container(
                height: 66,
                margin: const EdgeInsets.all(5),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColor.greyColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                    TextButton(
                      onPressed: () => _showDatePicker(context),
                      child: Text(
                        'SET',
                        style: TextConst.headingStyle(15, AppColor.redColor),
                      ),
                    ),
                  ],
                ),
              ),
              getTextFieldWithCareer(
                  _homeController, "Home", TextInputType.text),
              getTextFieldWithCareer(
                  _workController, "Work", TextInputType.text),
              getTextFieldWithCareer(
                  _collegeController, "College", TextInputType.text),
              getTextFieldWithCareer(
                  _schoolController, "School", TextInputType.text),
              GestureDetector(
                onTap: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    setState(() {
                      _isSigningUp = true;
                    });
                    _signUp();
                  }
                },
                child: Container(
                  height: 66,
                  margin: const EdgeInsets.all(10),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                    color: _formKey.currentState?.validate() ?? false
                        ? AppColor.redColor
                        : AppColor.whiteColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xffc2c2c2)),
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
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignInScreen()),
                      );
                    },
                    child: Text(
                      "Log in",
                      style: TextConst.headingStyle(15, AppColor.redColor),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
