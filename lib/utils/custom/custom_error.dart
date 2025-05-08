import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:socialseed/app/widgets/profile_widget.dart';
import 'package:socialseed/features/services/encryption_service.dart';
import 'package:socialseed/features/services/theme_service.dart';
import 'package:socialseed/main.dart';
import 'package:socialseed/utils/constants/color_const.dart';

class CustomErrorScreen extends StatelessWidget {
  final FlutterErrorDetails errorDetails;

  const CustomErrorScreen({super.key, required this.errorDetails});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: mq.height * 0.12,
                child: Lottie.asset(
                  'assets/animations/error-screen.json',
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Oops! Something went wrong.',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColor.redColor),
              ),
              const SizedBox(height: 10),
              Text(
                errorDetails.exceptionAsString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColor.textGreyColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  main();
                },
                child: Container(
                  height: 60,
                  width: double.infinity,
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: AppColor.redColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.blackColor,
                          blurRadius: 5,
                        ),
                      ]),
                  child: Center(
                      child: Text(
                    "Retry",
                    style: const TextStyle(
                      color: AppColor.whiteColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ErrorApp extends StatelessWidget {
  final FlutterErrorDetails errorDetails;

  const ErrorApp({super.key, required this.errorDetails});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr, // or TextDirection.rtl if needed
      child: MaterialApp(
        home: CustomErrorScreen(errorDetails: errorDetails),
      ),
    );
  }
}
