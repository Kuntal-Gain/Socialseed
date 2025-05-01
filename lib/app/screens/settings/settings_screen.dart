import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:socialseed/app/cubits/auth/auth_cubit.dart';
import 'package:socialseed/app/screens/settings/about_screen.dart';
import 'package:socialseed/app/screens/settings/account_privacy_screen.dart';
import 'package:socialseed/app/screens/settings/archived_content.dart';
import 'package:socialseed/app/screens/settings/edit_profile_screen.dart';
import 'package:socialseed/app/screens/settings/saved_posts_screen.dart';
import 'package:socialseed/app/screens/settings/verification_screen.dart';
import 'package:socialseed/domain/entities/user_entity.dart';
import 'package:socialseed/main.dart';
import 'package:socialseed/utils/constants/color_const.dart';
import 'package:socialseed/utils/constants/page_const.dart';
import 'package:socialseed/utils/constants/text_const.dart';

import '../../../features/services/theme_service.dart';
import '../../../utils/custom/custom_widgets.dart';

class SettingsScreen extends StatefulWidget {
  final UserEntity user;
  const SettingsScreen({super.key, required this.user});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<Settings> settings = [];

  @override
  void initState() {
    settings = [
      Settings(
          icon: Icons.person,
          option: "Edit Profile",
          page: EditProfileScreen(user: widget.user)),
      Settings(
        icon: Icons.bookmark,
        option: "Saved Content",
        page: SavedPostsScreen(
          user: widget.user,
        ),
      ),
      Settings(
        icon: Icons.archive,
        option: "Archived Content",
        page: ArchivedContentScreen(
          user: widget.user,
        ),
      ),
      Settings(
          icon: Icons.lock,
          option: "Account Privacy",
          page: PrivacySettingsScreen(
            userId: widget.user.uid!,
          )),
      Settings(
        icon: Icons.verified,
        option: "Request for Verification",
        page: RequestForVerificationScreen(
          uid: widget.user.uid!,
        ),
      ),
      const Settings(
        icon: Icons.info,
        option: "About Socialseed",
        page: AboutScreen(),
      ),
    ];
    super.initState();
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
        title: const Text('User Settings'),
      ),
      body: Column(
        children: [
          ListTile(
            leading: Icon(
              Provider.of<ThemeService>(context).isDarkMode
                  ? Icons.dark_mode
                  : Icons.light_mode,
              color: Provider.of<ThemeService>(context).isDarkMode
                  ? AppColor.whiteColor
                  : AppColor.blackColor,
            ),
            title: Text(
              '${Provider.of<ThemeService>(context).isDarkMode ? "Dark" : "Light"} Mode',
              style: TextConst.headingStyle(20, textColor),
            ),
            trailing: Switch(
              value: Provider.of<ThemeService>(context).isDarkMode,
              onChanged: (val) {
                Provider.of<ThemeService>(context, listen: false).toggleTheme();
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: settings.length,
              itemBuilder: (ctx, idx) {
                return GestureDetector(
                  onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => settings[idx].page)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        Icon(
                          settings[idx].icon,
                          size: 30,
                        ),
                        sizeHor(10),
                        Text(
                          settings[idx].option,
                          style: TextConst.headingStyle(20, textColor),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          GestureDetector(
            onTap: () {
              BlocProvider.of<AuthCubit>(context).logout().then((_) {
                Navigator.push(
                    // ignore: use_build_context_synchronously
                    context,
                    MaterialPageRoute(builder: (_) => const MyApp()));
              });
            },
            child: Container(
              margin: const EdgeInsets.all(12),
              height: 60,
              width: 200,
              decoration: BoxDecoration(
                color: AppColor.redColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  'Logout @${widget.user.fullname!.split(' ')[0]}',
                  style: TextConst.headingStyle(16, AppColor.whiteColor),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
