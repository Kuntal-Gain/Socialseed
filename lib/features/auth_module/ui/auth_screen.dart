import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socialseed/core/services/route_generator.dart';
import 'package:socialseed/core/utils/constants/color_const.dart';
import 'package:socialseed/core/utils/helpers/screen_utils.dart';
import 'package:socialseed/core/utils/helpers/scroll_view.dart';
import 'package:socialseed/core/utils/helpers/snackbar.dart';
import 'package:socialseed/core/utils/helpers/text_style.dart';
import 'package:socialseed/features/auth_module/ui/provider/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool isLogin = true;
  bool isVisible = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      body: CommonScreenWrapper(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              sizeVer(20),
              Image.asset("assets/images/SOCIALSEED.png"),

              Center(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    isLogin ? "Welcome Back" : "Join Us",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              // email field
              buildTextField(
                "Email",
                "Enter your email",
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
              ),
              // password field
              buildTextField(
                "Password",
                "Enter your password",
                icon: Icons.lock,
                isPassword: true,
                controller: _passwordController,
              ),
              // if (isLogin)
              //   Align(
              //     alignment: Alignment.bottomRight,
              //     child: Padding(
              //       padding: const EdgeInsets.symmetric(
              //         horizontal: 12,
              //         vertical: 10,
              //       ),
              //       child: Text(
              //         'Forgot Password ?',
              //         style: appTextStyle(
              //           fontSize: 14,
              //           fontWeight: FontWeight.bold,
              //           color: AppColor.redColor,
              //         ),
              //       ),
              //     ),
              //   ),

              GestureDetector(
                onTap: () async {
                  if (isLogin) {
                    final success =
                        await ref.read(authFormProvider.notifier).login(
                              AuthFormState(
                                email: _emailController.text,
                                password: _passwordController.text,
                              ),
                            );

                    if (success && context.mounted) {
                      successBar(context, "Login Successfull");

                      Navigator.of(context).pushNamedAndRemoveUntil(
                        RouteGenerator.kHome,
                        (route) => false,
                      );
                    } else {
                      failureBar(context, "Invalid Credentials");
                    }
                  } else {
                    await ref
                        .read(authFormProvider.notifier)
                        .signup(AuthFormState(
                          email: _emailController.text,
                          password: _passwordController.text,
                        ));

                    Navigator.of(context)
                        .pushNamed(RouteGenerator.kCreateAcc, arguments: {
                      'email': _emailController.text,
                    });
                  }
                },
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  decoration: BoxDecoration(
                    color: AppColor.redColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      isLogin ? 'Login' : 'Sign Up',
                      style: appTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColor.whiteColor,
                      ),
                    ),
                  ),
                ),
              ),

              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isLogin
                            ? 'Don\'t have an account?'
                            : 'Already have an account?',
                        style: appTextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: AppColor.blackColor,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            isLogin = !isLogin;
                          });
                        },
                        child: Text(
                          !isLogin ? 'Login' : 'Signup',
                          style: appTextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColor.redColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
    String label,
    String hintText, {
    bool isPassword = false,
    IconData? icon = Icons.email,
    TextInputType keyboardType = TextInputType.text,
    TextEditingController? controller,
  }) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColor.textGreyColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            keyboardType: keyboardType,
            obscureText: isPassword && !isVisible,
            controller: controller,
            style: const TextStyle(color: AppColor.blackColor, fontSize: 12),
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: AppColor.textGreyColor,
              ),
              suffixIcon: isPassword
                  ? GestureDetector(
                      onTap: () {
                        setState(() {
                          isVisible = !isVisible;
                        });
                      },
                      child: Icon(
                        !isVisible ? Icons.visibility : Icons.visibility_off,
                        color: AppColor.textGreyColor,
                      ),
                    )
                  : null,
              hintText: hintText,
              hintStyle: const TextStyle(color: AppColor.textGreyColor),
              filled: true,
              fillColor: AppColor.whiteColor,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: AppColor.redColor,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
