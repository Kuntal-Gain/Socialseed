import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socialseed/app/screens/credential/username_screen.dart';
import 'package:socialseed/utils/constants/color_const.dart';
import '../screens/credential/signup_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Start the timer
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NewScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/leafImage.png.png',
              width: MediaQuery.of(context).size.width *
                  0.5, // Adjust size based on screen width
              height: MediaQuery.of(context).size.height *
                  0.25, // Adjust size based on screen height
            ),
            const SizedBox(height: 30),
            const Text(
              'SOCIAL SEED',
              style: TextStyle(
                color: Colors.red,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NewScreen extends StatelessWidget {
  const NewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: OpacityAnimationWidget(),
      ),
    );
  }
}

class OpacityAnimationWidget extends StatefulWidget {
  const OpacityAnimationWidget({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _OpacityAnimationWidgetState createState() => _OpacityAnimationWidgetState();
}

class _OpacityAnimationWidgetState extends State<OpacityAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _opacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 1), // Full animation duration
      ),
    );

    _controller.forward(); // Start the animation
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            width: screenWidth * 0.9,
            height: screenHeight * 0.9,
            color: Colors.white,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_controller.value >= 0)
                  Positioned(
                    top: screenHeight * 0.02, // Adjust position based on height
                    child: Opacity(
                      opacity: _controller.value,
                      child: Image.asset(
                        'assets/logo.png',
                        width: screenWidth *
                            0.8, // Adjust width based on screen size
                        height: screenHeight *
                            0.25, // Adjust height based on screen size
                      ),
                    ),
                  ),
                if (_controller.value >= 0.3)
                  Opacity(
                    opacity: _opacityAnimation.value,
                    child: Center(
                      child: Image.asset(
                        'assets/splash.jpg',
                        width: screenWidth *
                            0.9, // Adjust width based on screen size
                        height: screenHeight *
                            0.3, // Adjust height based on screen size
                      ),
                    ),
                  ),
                if (_controller.value >= 0.6)
                  Positioned(
                    top: screenHeight * 0.7, // Adjust based on screen size
                    child: Opacity(
                      opacity: _opacityAnimation.value,
                      child: const Text(
                        'Fueling Connections,\nSparking Conversation',
                        style: TextStyle(
                            fontSize: 24,
                            color: Colors.red,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                if (_controller.value >= 0.9)
                  Positioned(
                    bottom: 30 + (_controller.value - 1.25) * 100,
                    child: Opacity(
                      opacity: _opacityAnimation.value,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (ctx) => const UsernameScreen()));
                        },
                        child: Container(
                          height:
                              screenHeight * 0.08, // Responsive button height
                          width: screenWidth * 0.85, // Responsive button width
                          decoration: BoxDecoration(
                            color: AppColor.redColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          margin: const EdgeInsets.all(12),
                          child: Center(
                            child: Text(
                              'Start Your Journey Now',
                              style: GoogleFonts.montserrat(
                                textStyle: TextStyle(
                                  color: AppColor.whiteColor,
                                  fontSize: screenHeight *
                                      0.025, // Responsive font size
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
