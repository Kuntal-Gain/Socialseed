import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:socialseed/core/services/route_generator.dart';
import 'package:socialseed/core/utils/constants/color_const.dart';
import 'package:socialseed/core/utils/helpers/appbar.dart';
import 'package:socialseed/core/utils/helpers/scroll_view.dart';
import 'package:socialseed/core/utils/helpers/screen_utils.dart';
import 'package:socialseed/core/utils/helpers/text_style.dart';
import 'package:socialseed/features/auth_module/ui/provider/auth_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppbar(title: 'Settings'),
      backgroundColor: AppColor.whiteColor,
      body: CommonScreenWrapper(
        containsScrollable: true,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Preferences'),
                sizeVer(12),
                _buildSettingsTile(
                  icon: HugeIconsStroke.moon,
                  title: 'Dark Mode',
                  subtitle: 'Switch to dark theme',
                  isSwitch: true,
                  value: isDarkMode,
                  onChanged: (value) {
                    setState(() {
                      isDarkMode = value;
                    });
                  },
                ),
                sizeVer(20),
                _buildSectionTitle('Account'),
                sizeVer(12),
                _buildSettingsTile(
                  icon: HugeIconsStroke.user,
                  title: 'Update Profile',
                  subtitle: 'Edit your personal information',
                  onTap: () {
                    // Navigate to update profile
                  },
                ),
                sizeVer(8),
                _buildSettingsTile(
                  icon: HugeIconsStroke.checkmarkBadge01,
                  title: 'Verification Status',
                  subtitle: 'Check your account verification',
                  onTap: () {
                    // Navigate to verification status
                    Navigator.of(context).pushNamed(RouteGenerator.kVerify);
                  },
                ),
                sizeVer(8),
                _buildSettingsTile(
                  icon: HugeIconsStroke.award01,
                  title: 'Milestones',
                  subtitle: 'View your achievements',
                  onTap: () {
                    // Navigate to milestones
                    Navigator.of(context).pushNamed(RouteGenerator.kMilestones);
                  },
                ),
                sizeVer(30),
                _buildLogoutButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: appTextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColor.textGreyColor,
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isSwitch = false,
    bool value = false,
    Function(bool)? onChanged,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: isSwitch ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColor.greyColor),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColor.redColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 24,
                color: AppColor.redColor,
              ),
            ),
            sizeHor(14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: appTextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColor.blackColor,
                    ),
                  ),
                  sizeVer(4),
                  Text(
                    subtitle,
                    style: appTextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.normal,
                      color: AppColor.textGreyColor,
                    ),
                  ),
                ],
              ),
            ),
            isSwitch
                ? Transform.scale(
                    scale: 0.9,
                    child: Switch(
                      value: value,
                      onChanged: onChanged,
                      activeColor: AppColor.redColor,
                      activeTrackColor: AppColor.redColor.withOpacity(0.5),
                    ),
                  )
                : Icon(
                    Icons.chevron_right_rounded,
                    size: 28,
                    color: AppColor.textGreyColor,
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: () {
        ref.read(authFormProvider.notifier).logout();
        Navigator.pushNamedAndRemoveUntil(
          context,
          RouteGenerator.kAuth,
          (route) => false,
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColor.redColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColor.redColor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              HugeIconsStroke.logout01,
              size: 22,
              color: AppColor.redColor,
            ),
            sizeHor(10),
            Text(
              'Logout',
              style: appTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColor.redColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
