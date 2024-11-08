// ignore_for_file: library_private_types_in_public_api

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:socialseed/app/cubits/archivepost/archivepost_cubit.dart';
import 'package:socialseed/app/cubits/auth/auth_cubit.dart';
import 'package:socialseed/app/cubits/comment/cubit/comment_cubit.dart';
import 'package:socialseed/app/cubits/credential/credential_cubit.dart';
import 'package:socialseed/app/cubits/get_single_other_user/get_single_other_user_cubit.dart';
import 'package:socialseed/app/cubits/get_single_user/get_single_user_cubit.dart';
import 'package:socialseed/app/cubits/message/message_cubit.dart';
import 'package:socialseed/app/cubits/story/story_cubit.dart';
import 'package:socialseed/app/cubits/users/user_cubit.dart';
import 'package:socialseed/app/cubits/post/post_cubit.dart';
import 'package:socialseed/app/cubits/message/chat_id/chat_cubit.dart';
import 'package:socialseed/app/screens/home_screen.dart';
import 'package:socialseed/firebase_options.dart';
// Added
import 'package:socialseed/utils/constants/color_const.dart';

import 'app/cubits/savedcontent/savedcontent_cubit.dart';
import 'app/screens/no_internet.dart';
import 'app/widgets/opacity_leaf_animation.dart';
import 'dependency_injection.dart' as di;
import 'package:flutter_bloc/flutter_bloc.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthCubit>()..appStarted(context)),
        BlocProvider(create: (_) => di.sl<CredentialCubit>()),
        BlocProvider(create: (_) => di.sl<UserCubit>()),
        BlocProvider(create: (_) => di.sl<GetSingleUserCubit>()),
        BlocProvider(create: (_) => di.sl<PostCubit>()),
        BlocProvider(create: (_) => di.sl<CommentCubit>()),
        BlocProvider(create: (_) => di.sl<GetSingleOtherUserCubit>()),
        BlocProvider(create: (_) => di.sl<ChatCubit>()),
        BlocProvider(create: (_) => di.sl<MessageCubit>()),
        BlocProvider(create: (_) => di.sl<StoryCubit>()),
        BlocProvider(create: (_) => di.sl<SavedcontentCubit>()),
        BlocProvider(create: (_) => di.sl<ArchivepostCubit>()),
      ],
      child: MaterialApp(
        theme: ThemeData(
          primaryColor: Colors.white,
          textTheme: ThemeData.light().textTheme.apply(
                bodyColor: AppColor.blackColor,
                displayColor: AppColor.blackColor,
              ),
        ),
        darkTheme: ThemeData.dark().copyWith(
          textTheme: ThemeData.dark().textTheme.apply(
                bodyColor: AppColor.blackColor,
                displayColor: AppColor.blackColor,
              ),
        ),
        debugShowCheckedModeBanner: false,
        home: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            if (state is Authenticated) {
              return HomeScreen(uid: state.uid);
            } else if (state is NoInternet) {
              return const NoInternetScreen(); // Show the No Internet screen
            } else if (state is NotAuthenticated) {
              return const SplashScreen();
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}
