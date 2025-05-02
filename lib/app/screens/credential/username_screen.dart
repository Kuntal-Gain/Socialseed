import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:socialseed/app/screens/credential/signup_screen.dart';
import 'package:socialseed/utils/constants/color_const.dart';
import 'package:socialseed/utils/constants/firebase_const.dart';
import 'package:socialseed/utils/custom/custom_snackbar.dart';

import '../../../features/services/theme_service.dart';
import '../../../utils/constants/page_const.dart';
import '../../../utils/constants/text_const.dart';

class UsernameScreen extends StatefulWidget {
  const UsernameScreen({super.key});

  @override
  State<UsernameScreen> createState() => _UsernameScreenState();
}

class _UsernameScreenState extends State<UsernameScreen> {
  final _usernameController = TextEditingController();

  bool _isSigningUp = false;
  bool isUsernameUnique = false;

  List<String> rules = [
    'Username is required',
    'Username must be at least 6 characters long',
    'Username must not contain special characters',
    'Username must not contain spaces',
    'Username should be unique'
  ];

  bool isRuleFulfilled(String rule) {
    final username = _usernameController.text.trim();

    switch (rule) {
      case 'Username is required':
        return username.isNotEmpty;

      case 'Username must be at least 6 characters long':
        return username.length >= 6;

      case 'Username must not contain special characters':
        return !username.contains(RegExp(r"[!@#\$%\^&*]"));

      case 'Username must not contain spaces':
        return !username.contains(RegExp(r'\s'));

      case 'Username should be unique':
        return isUsernameUnique;

      default:
        return false;
    }
  }

  Widget getTextField(
      TextEditingController controller, String label, TextInputType key) {
    final textColor = Provider.of<ThemeService>(context).isDarkMode
        ? AppColor.whiteColor
        : AppColor.blackColor;

    final secondary = Provider.of<ThemeService>(context).isDarkMode
        ? AppColor.secondaryDark
        : AppColor.greyColor;

    return Container(
      height: 66,
      width: double.infinity,
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: secondary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: key,
        onChanged: (value) async {
          final isTaken = await checkUsername(value);
          setState(() {
            isUsernameUnique = !isTaken;
          });
        },
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: label,
        ),
      ),
    );
  }

  Future<bool> checkUsername(String username) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection(FirebaseConst.users)
          .where('username', isEqualTo: username)
          .limit(1)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(() {
      setState(() {}); // Rebuild UI when username changes
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Provider.of<ThemeService>(context).isDarkMode
        ? AppColor.whiteColor
        : AppColor.blackColor;

    final mq = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              sizeVar(20),
              Center(child: Image.asset('assets/SOCIALSEED.png')),
              const SizedBox(height: 20),
              Text(
                'Join Now',
                style: TextConst.MediumStyle(mq.width * 0.1, textColor),
              ),
              const SizedBox(height: 8),
              Text(
                "Let's get started by filling out the form below.",
                style: TextConst.RegularStyle(15, textColor),
              ),
              const SizedBox(height: 15),
              getTextField(_usernameController, 'Username', TextInputType.text),
              const SizedBox(height: 15),
              Text(
                'Rules',
                style: TextConst.MediumStyle(mq.width * 0.05, textColor),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                itemCount: rules.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final isFulfilled = isRuleFulfilled(rules[index]);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Icon(
                          isFulfilled ? Icons.check : Icons.close,
                          color: isFulfilled ? Colors.green : AppColor.redColor,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: isFulfilled ? 1.0 : 0.5,
                          child: Text(
                            rules[index],
                            style: TextConst.headingStyle(15, textColor),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  setState(() => _isSigningUp = true);
                  String username = _usernameController.text.trim();

                  bool allRulesPassed = rules
                      .where((rule) => rule != 'Username should be unique')
                      .every((rule) => isRuleFulfilled(rule));

                  if (!allRulesPassed) {
                    failureBar(context,
                        'Please fulfill all username rules before proceeding.');
                    setState(() => _isSigningUp = false);
                    return;
                  }

                  if (!isUsernameUnique) {
                    failureBar(
                        context, 'Username already exists, try another one.');
                    setState(() {
                      _isSigningUp = false;
                      isUsernameUnique = false;
                    });
                  } else {
                    setState(() {
                      isUsernameUnique = true;
                      _isSigningUp = false;
                    });
                    successBar(context, 'Username is valid and available!');

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SignUpScreen(username: username),
                      ),
                    );
                  }
                },
                child: Container(
                  height: 66,
                  width: double.infinity,
                  margin: const EdgeInsets.all(10),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppColor.redColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: !_isSigningUp
                        ? Text(
                            isUsernameUnique ? "Check" : "Next",
                            style:
                                TextConst.headingStyle(18, AppColor.whiteColor),
                          )
                        : const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 14.0),
                    child: Text("Already have an account?"),
                  ),
                  TextButton(
                    onPressed: () {
                      // Handle login navigation here
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
                  style: TextConst.RegularStyle(18, textColor),
                ),
              ),
              sizeVar(30),
            ],
          ),
        ),
      ),
    );
  }
}
