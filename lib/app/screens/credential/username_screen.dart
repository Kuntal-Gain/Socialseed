import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:socialseed/utils/constants/color_const.dart';
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
        return false;

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
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: label,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(() {
      setState(() {}); // Rebuild on each keystroke
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

    final secondary = Provider.of<ThemeService>(context).isDarkMode
        ? AppColor.secondaryDark
        : AppColor.greyColor;

    final mq = MediaQuery.of(context).size;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sizeVar(20),
          Image.asset('assets/SOCIALSEED.png'),
          const SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * 0.03),
            child: Text(
              'Join Now',
              style: TextConst.MediumStyle(
                mq.width * 0.1, // Adjust text size with MediaQuery
                textColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * 0.03),
            child: Text(
              "Let's get started by filling out the form below.",
              style: TextConst.RegularStyle(15, textColor),
            ),
          ),
          const SizedBox(height: 15),
          getTextField(_usernameController, 'Username', TextInputType.text),
          const SizedBox(height: 15),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * 0.01),
            child: Text(
              'Rules',
              style: TextConst.MediumStyle(
                mq.width * 0.05, // Adjust text size with MediaQuery
                textColor,
              ),
            ),
          ),
          SizedBox(
            height: mq.height * 0.15,
            child: ListView.builder(
              itemCount: rules.length,
              itemBuilder: (context, index) {
                final isFulfilled = isRuleFulfilled(rules[index]);

                return Row(
                  children: [
                    Icon(
                      isFulfilled ? Icons.check : Icons.close,
                      color: isFulfilled ? Colors.green : AppColor.redColor,
                    ),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: isFulfilled ? 1.0 : 0.5,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(
                          rules[index],
                          style: TextConst.headingStyle(15, textColor),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          GestureDetector(
            onTap: () {
              // setState(() {
              //   _isSigningUp = true;
              // });
            },
            child: Container(
              height: 66,
              width: double.infinity,
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                color: AppColor.redColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: !_isSigningUp
                    ? Text(
                        "Login",
                        style: TextConst.headingStyle(18, AppColor.whiteColor),
                      )
                    : CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 14.0),
                child: Text(
                  "Already have an account?",
                  style: TextConst.RegularStyle(15, textColor),
                ),
              ),
              TextButton(
                onPressed: () {},
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
    );
  }
}
