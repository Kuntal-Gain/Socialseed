// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:socialseed/app/screens/credential/signin_screen.dart';
import 'package:socialseed/app/screens/credential/signup_screen.dart';
import 'package:socialseed/utils/constants/color_const.dart';
import 'package:socialseed/utils/constants/page_const.dart';
import 'package:socialseed/utils/constants/text_const.dart';

class OnGenerateRoutes {
  static Route<dynamic>? route(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case PageConst.registerPage:
        return routeBuilder(const SignUpScreen());
      case PageConst.loginPage:
        return routeBuilder(const SignInScreen());

      default:
        return routeBuilder(const NoPageFound());
    }
  }
}

dynamic routeBuilder(Widget child) =>
    MaterialPageRoute(builder: (ctx) => child);

class NoPageFound extends StatelessWidget {
  const NoPageFound({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BACK TO HOMEPAGE"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushNamed('/registerPage');
          },
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Image.asset('assets/404.jpg'),
          Text(
            'Something Went Wrong!!',
            style: TextConst.headingStyle(
              21,
              AppColor.redColor,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            child: Text(
              'You Can Try : \n1.Check Your Internet Connection is Stable\n2.Requested Page is Maybe Not Exists or Removed\n3.Send Troubleshoot to our Support Team',
              style: TextConst.MediumStyle(
                18,
                AppColor.textGreyColor,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Send Troubleshoot'),
          )
        ],
      ),
    );
  }
}
