import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socialseed/core/services/route_generator.dart';
import 'package:socialseed/core/utils/constants/color_const.dart';
import 'package:socialseed/core/utils/helpers/screen_utils.dart';
import 'package:socialseed/core/utils/helpers/text_style.dart';
import 'package:socialseed/features/auth_module/ui/provider/auth_provider.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(getAuthStateProvider);

    ref.listen(getAuthStateProvider, (prev, next) {
      next.whenData((isLoggedIn) {
        if (isLoggedIn) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Future.delayed(const Duration(seconds: 2), () {
              Navigator.of(context).pushReplacementNamed(RouteGenerator.kHome);
            });
          });
        }
      });
    });

    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      body: Column(
        children: [
          SizedBox(height: ScreenUtils().screenHeight(context) * 0.07),
          Image.asset('assets/images/SOCIALSEED.png'),
          Image.asset('assets/images/splash.jpg'),
          const Spacer(),
          Text(
            'Fueling Connections, Sparking Conversations',
            style: appTextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: AppColor.redColor,
            ),
          ),
          const SizedBox(height: 12),
          authState.when(
            loading: () => const Padding(
              padding: EdgeInsets.only(bottom: 40),
              child: CircularProgressIndicator(),
            ),
            error: (e, _) => const Text("Auth error 😵‍💫"),
            data: (isLoggedIn) {
              if (isLoggedIn) {
                return const Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: CircularProgressIndicator(
                    color: AppColor.redColor,
                  ),
                );
              }

              return GestureDetector(
                onTap: () {
                  Navigator.of(context)
                      .pushReplacementNamed(RouteGenerator.kAuth);
                },
                child: Container(
                  height: ScreenUtils().screenHeight(context) * 0.06,
                  width: ScreenUtils().screenWidth(context) * 0.9,
                  decoration: BoxDecoration(
                    color: AppColor.redColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      'Start Your Journey',
                      style: appTextStyle(
                        fontSize: 19,
                        color: AppColor.whiteColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: ScreenUtils().screenHeight(context) * 0.06),
        ],
      ),
    );
  }
}
