import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialseed/app/cubits/credential/credential_cubit.dart';
import 'package:socialseed/features/services/theme_service.dart';
import 'package:socialseed/utils/constants/color_const.dart';
import 'package:socialseed/utils/constants/page_const.dart';
import 'package:socialseed/utils/constants/text_const.dart';
import 'package:socialseed/dependency_injection.dart' as di;
import 'package:socialseed/utils/custom/custom_snackbar.dart';

class ForgotScreen extends StatefulWidget {
  const ForgotScreen({super.key});

  @override
  State<ForgotScreen> createState() => _ForgotScreenState();
}

class _ForgotScreenState extends State<ForgotScreen> {
  final _emailController = TextEditingController();
  bool isLoading = false;

  Widget getTextField(
      TextEditingController controller, String label, TextInputType key) {
    final textColor = Provider.of<ThemeService>(context).isDarkMode
        ? AppColor.whiteColor
        : AppColor.blackColor;

    final secondaryColor = Provider.of<ThemeService>(context).isDarkMode
        ? AppColor.secondaryDark
        : AppColor.whiteColor;
    return Container(
      height: 66,
      width: double.infinity,
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: secondaryColor,
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
  Widget build(BuildContext context) {
    final bg = Provider.of<ThemeService>(context).isDarkMode
        ? AppColor.bgDark
        : AppColor.whiteColor;
    final textColor = Provider.of<ThemeService>(context).isDarkMode
        ? AppColor.whiteColor
        : AppColor.blackColor;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: const Text('Back'),
      ),
      body: Column(
        children: [
          Center(
            child: Text(
              'Forgot Password',
              style: TextConst.MediumStyle(
                40,
                textColor,
              ),
            ),
          ),
          sizeVar(10),
          Text(
            'We will send you an email with a link to reset your password, please enter the email associated with your account below.',
            style: TextConst.MediumStyle(
              18,
              textColor,
            ),
            textAlign: TextAlign.center,
          ),
          sizeVar(20),
          getTextField(
            _emailController,
            "E-mail",
            TextInputType.emailAddress,
          ),
          GestureDetector(
            onTap: () async {
              if (_emailController.text.isEmpty) {
                failureBar(context, "Please Enter your Email Address");
                return;
              }

              setState(() {
                isLoading = true;
              });

              try {
                await di
                    .sl<CredentialCubit>()
                    .forgotPassword(email: _emailController.text);
                // ignore: use_build_context_synchronously
                successBar(context, "Request has been sent to you Email");
              } catch (error) {
                // ignore: use_build_context_synchronously
                failureBar(context, "Error : $error");
              } finally {
                setState(() {
                  isLoading = false;
                });
              }
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
                child: !isLoading
                    ? Text(
                        "Send Request",
                        style: TextConst.headingStyle(18, AppColor.whiteColor),
                      )
                    : const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
