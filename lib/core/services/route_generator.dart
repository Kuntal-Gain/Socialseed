import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:socialseed/core/utils/helpers/font_sizes.dart';
import 'package:socialseed/features/auth_module/ui/auth_screen.dart';
import 'package:socialseed/features/auth_module/ui/create_user_screen.dart';
import 'package:socialseed/features/story/ui/story_upload_screen.dart';
import 'package:socialseed/features/home/ui/home_screen.dart';
import 'package:socialseed/features/post/ui/post_creation_screen.dart';
import 'package:socialseed/features/profile/ui/profile_screen.dart';
import 'package:socialseed/features/splash_module/ui/splash_screen.dart';
import 'package:socialseed/features/story/ui/story_viewer_screen.dart';

import '../../features/post/ui/post_view_screen.dart';

class RouteGenerator {
  static const kSplash = "/";

  /// [auth]
  static const kAuth = "/auth";
  static const kCreateAcc = "/createAcc";

  /// [home]
  static const kHome = "/home";
  static const kStory = "/StoryViewScreen";

  /// [POST]
  static const kPostCreate = "/CreatePost";
  static const kPostView = "/PostView";
  static const kStoryUpload = "/StoryUpload";

  /// [profile]
  static const kProfile = "/Profile";

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    // final args = settings.arguments;

    switch (settings.name) {
      case kSplash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case kAuth:
        return _animatedPageRoute(AuthScreen());
      case kCreateAcc:
        final args = settings.arguments as Map<String, dynamic>;

        return _animatedPageRoute(CreateAccountScreen(
          email: args['email'],
        ));

      case kHome:
        return _animatedPageRoute(HomeScreen());

      case kStory:
        final args = settings.arguments as Map<String, dynamic>;

        return _animatedPageRoute(StoryViewScreen(story: args['story']));

      /// [POST] routes
      case kPostCreate:
        return _animatedPageRoute(PostCreationScreen());
      case kPostView:
        final args = settings.arguments as Map<String, dynamic>;

        return _animatedPageRoute(PostViewScreen(
          post: args['post'],
        ));

      case kProfile:
        final args = settings.arguments as Map<String, dynamic>;

        return _animatedPageRoute(UserProfileScreen(
          uid: args['uid'],
        ));

      case kStoryUpload:
        return _animatedPageRoute(StoryUploadScreen());

      default:
        return _errorRoute(errorMessage: "Route not found: ${settings.name}");
    }
  }

  static Route<dynamic> _animatedPageRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) {
        return page; // The page to navigate to
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Define the transition animation

        // Slide from the right (Offset animation)
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        final curve = Curves.easeInToLinear; // A more natural easing curve

        var offsetTween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(offsetTween);

        // Scale transition (page zooms in slightly)
        var scaleTween = Tween(begin: 0.95, end: 1.0);
        var scaleAnimation = animation.drive(scaleTween);

        // Fade transition (opacity increases from 0 to 1)
        var fadeTween = Tween(begin: 0.0, end: 1.0);
        var fadeAnimation = animation.drive(fadeTween);

        // Return a combination of Slide, Fade, and Scale
        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: ScaleTransition(
              scale: scaleAnimation,
              child: Material(
                color: Colors.transparent,
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 5.0,
                    sigmaY: 5.0,
                  ), // Add blur effect
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static Route<dynamic> _errorRoute({String errorMessage = ''}) {
    return MaterialPageRoute(
      builder: (ctx) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              "Error",
              style: Theme.of(
                ctx,
              ).textTheme.displayMedium?.copyWith(color: Colors.black),
            ),
          ),
          body: Center(
            child: Column(
              children: [
                Text(
                  "Oops something went wrong",
                  style: Theme.of(ctx).textTheme.displayMedium?.copyWith(
                        fontSize: AppFontSize.textExtraLarge,
                        color: Colors.black,
                      ),
                ),
                Text(
                  errorMessage,
                  style: Theme.of(ctx).textTheme.displayMedium?.copyWith(
                        fontSize: AppFontSize.textExtraLarge,
                        color: Colors.black,
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
