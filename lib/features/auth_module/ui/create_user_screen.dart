import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scroll_date_picker/scroll_date_picker.dart';
import 'package:socialseed/core/provider/user_provider.dart';
import 'package:socialseed/core/services/route_generator.dart';
import 'package:socialseed/core/utils/constants/color_const.dart';
import 'package:socialseed/core/utils/helpers/screen_utils.dart';
import 'package:socialseed/core/utils/helpers/text_style.dart';
import 'package:socialseed/features/auth_module/model/user_model.dart';
import 'package:socialseed/features/auth_module/ui/provider/creds_provider.dart';

class CreateAccountScreen extends ConsumerStatefulWidget {
  final String email;
  const CreateAccountScreen({super.key, required this.email});

  @override
  ConsumerState<CreateAccountScreen> createState() =>
      _CreateAccountScreenState();
}

class _CreateAccountScreenState extends ConsumerState<CreateAccountScreen> {
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _cityController = TextEditingController();
  final _schoolController = TextEditingController();
  final _collegeController = TextEditingController();
  final _workspaceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  DateTime? selectedDate;
  String? avatarPath;

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _cityController.dispose();
    _schoolController.dispose();
    _collegeController.dispose();
    _workspaceController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  void createUser() async {
    final uid = await ref.read(getCurrentUidProvider);
    final user = User(
      uid: uid,
      email: widget.email,
      fullName: _fullNameController.text,
      username: _usernameController.text,
      dateOfBirth: Timestamp.fromDate(selectedDate ?? DateTime.now()),
      address: null,
      profileHistory: null,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
      isProfileCompleted: false,
      isVerified: false,
      isOnline: false,
    );

    await ref.read(credsProvider.notifier).createUser(user);
    Navigator.of(context)
        .pushNamedAndRemoveUntil(RouteGenerator.kHome, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  sizeVer(20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Image.asset("assets/images/SOCIALSEED.png"),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Complete Profile",
                          style: TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.w500,
                            color: AppColor.blackColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Tell us more about yourself",
                          style: appTextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: AppColor.textGreyColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Avatar Section
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: GestureDetector(
                        onTap: () {
                          // TODO: Implement image picker
                          // Pick image and set avatarPath
                        },
                        child: Stack(
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey[100],
                                border: Border.all(
                                  color:
                                      const Color(0xFFFF3131).withOpacity(0.3),
                                  width: 3,
                                ),
                              ),
                              child: avatarPath != null
                                  ? ClipOval(
                                      child: Image.asset(
                                        avatarPath!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Icon(
                                      Icons.person_outline,
                                      size: 60,
                                      color: AppColor.textGreyColor,
                                    ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF3131),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Color(0xFFFF3131),
                                    width: 3,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: AppColor.whiteColor,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Center(
                      child: Text(
                        "Upload Profile Photo",
                        style: appTextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColor.textGreyColor,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Full Name field (Required)
                  buildTextField(
                    "Full Name",
                    "Enter your full name",
                    icon: Icons.person_outline,
                    keyboardType: TextInputType.name,
                    controller: _fullNameController,
                    isRequired: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Full name is required';
                      }
                      return null;
                    },
                  ),

                  // Username field (Required)
                  buildTextField(
                    "Username",
                    "Choose a unique username",
                    icon: Icons.alternate_email,
                    keyboardType: TextInputType.text,
                    controller: _usernameController,
                    isRequired: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Username is required';
                      }
                      if (value.contains(' ')) {
                        return 'Username cannot contain spaces';
                      }
                      return null;
                    },
                  ),

                  // Date of Birth (Required)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Date of Birth",
                              style: appTextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColor.blackColor,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              "*",
                              style: TextStyle(
                                color: Color(0xFF3131),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _openDobBottomSheet(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: selectedDate != null
                                    ? const Color(0xFF3131)
                                    : Colors.grey[200]!,
                                width: selectedDate != null ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  color: AppColor.textGreyColor,
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  selectedDate != null
                                      ? _formatDate(selectedDate!)
                                      : "Select your date of birth",
                                  style: appTextStyle(
                                    fontSize: 15,
                                    color: selectedDate != null
                                        ? AppColor.blackColor
                                        : AppColor.textGreyColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // City field (Optional)
                  buildTextField(
                    "City",
                    "Enter your city",
                    icon: Icons.location_city_outlined,
                    keyboardType: TextInputType.text,
                    controller: _cityController,
                    isRequired: false,
                  ),

                  // School field (Optional)
                  buildTextField(
                    "School",
                    "Enter your school name",
                    icon: Icons.school_outlined,
                    keyboardType: TextInputType.text,
                    controller: _schoolController,
                    isRequired: false,
                  ),

                  // College field (Optional)
                  buildTextField(
                    "College",
                    "Enter your college name",
                    icon: Icons.business_outlined,
                    keyboardType: TextInputType.text,
                    controller: _collegeController,
                    isRequired: false,
                  ),

                  // Workspace field (Optional)
                  buildTextField(
                    "Workspace",
                    "Enter your workplace",
                    icon: Icons.work_outline,
                    keyboardType: TextInputType.text,
                    controller: _workspaceController,
                    isRequired: false,
                  ),

                  const SizedBox(height: 24),

                  // Create Account Button
                  GestureDetector(
                    onTap: () async {
                      if (_formKey.currentState!.validate()) {
                        if (selectedDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Please select your date of birth',
                                style: appTextStyle(
                                  fontSize: 14,
                                  color: AppColor.whiteColor,
                                ),
                              ),
                              backgroundColor: const Color(0xFF3131),
                            ),
                          );
                          return;
                        }

                        createUser();
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF3131),
                        borderRadius: BorderRadius.circular(7.5),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF3131).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Create Account',
                          style: appTextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColor.whiteColor,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
    String label,
    String hintText, {
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    TextEditingController? controller,
    bool isRequired = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: appTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColor.blackColor,
                ),
              ),
              if (isRequired)
                const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Text(
                    "*",
                    style: TextStyle(
                      color: Color(0xFF3131),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            keyboardType: keyboardType,
            controller: controller,
            validator: validator,
            style: appTextStyle(
              fontSize: 16,
              color: AppColor.blackColor,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: AppColor.textGreyColor,
                size: 22,
              ),
              hintText: hintText,
              hintStyle: appTextStyle(
                fontSize: 15,
                color: AppColor.textGreyColor,
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFF3131),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 1,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openDobBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          width: ScreenUtils().screenWidth(context),
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Text(
                "Select Date of Birth",
                style: appTextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColor.blackColor,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 250,
                child: ScrollDatePicker(
                  selectedDate: selectedDate ?? DateTime.now(),
                  locale: Locale('en'),
                  onDateTimeChanged: (DateTime value) {
                    setState(() {
                      selectedDate = value;
                    });
                  },
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF3131),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF3131).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Select Date',
                      style: appTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColor.whiteColor,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
