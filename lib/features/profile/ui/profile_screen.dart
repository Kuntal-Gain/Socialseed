import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socialseed/core/services/route_generator.dart';
import 'package:socialseed/core/utils/constants/color_const.dart';
import 'package:socialseed/core/utils/helpers/app_loader.dart';
import 'package:socialseed/core/utils/helpers/appbar.dart';
import 'package:socialseed/core/utils/helpers/datetime_helper.dart';
import 'package:socialseed/core/utils/helpers/failure_widget.dart';
import 'package:socialseed/core/utils/helpers/screen_utils.dart';
import 'package:socialseed/core/utils/helpers/scroll_view.dart';
import 'package:socialseed/core/utils/helpers/text_style.dart';
import 'package:socialseed/features/auth_module/model/user_model.dart';
import 'package:socialseed/features/auth_module/ui/provider/auth_provider.dart';
import 'package:socialseed/features/auth_module/ui/provider/creds_provider.dart';
import 'package:socialseed/features/feed/ui/widget/post_widget.dart';
import 'package:socialseed/features/post/model/post_model.dart';
import 'package:socialseed/features/post/ui/provider/post_provider.dart';
import 'package:socialseed/features/profile/ui/widgets/edit_profile_bottom_sheet.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  final String? uid;
  const UserProfileScreen({super.key, this.uid});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging == false) {
        setState(() {
          _currentIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String naStr(String? str) => str ?? 'NA';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
        widget.uid == null ? credsProvider : userByIdProvider(widget.uid!));
    final postsCnt = ref.watch(userPostsCountProvider);

    return Scaffold(
      appBar: widget.uid != null
          ? CommonAppbar(
              title: 'User Profile',
            )
          : null,
      backgroundColor: AppColor.whiteColor,
      body: RefreshIndicator(
        color: AppColor.redColor,
        onRefresh: () async {
          ref.invalidate(credsProvider);
        },
        child: CommonScreenWrapper(
          containsScrollable: true,
          body: state.when(
              loading: () => AppLoader().stateLoader(),
              error: (error, stack) => Center(child: Text('Error: $error')),
              data: (user) {
                return SafeArea(
                  child: Column(
                    children: [
                      // sizeVer(30),

                      SizedBox(
                        height: 220,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Cover Image
                            Container(
                              height: 160,
                              width: double.infinity,
                              margin: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: const DecorationImage(
                                  image: NetworkImage(
                                    'https://images.unsplash.com/photo-1579546929518-9e396f3cc809?w=800',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                                color: Colors.grey.shade300,
                              ),
                            ),

                            // Profile Picture (Centered and Overlapping)
                            Positioned(
                              bottom: -10,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.15),
                                        blurRadius: 15,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  // child: CircleAvatar(
                                  //   radius: 60,
                                  //   backgroundImage: NetworkImage(
                                  //     user?.avatar != ""
                                  //         ? user?.avatar ?? ""
                                  //         : 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=300',
                                  //   ),
                                  //   child: CachedNetworkImage(
                                  //     imageUrl: user?.avatar != ""
                                  //         ? user?.avatar ?? ""
                                  //         : 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=300',
                                  //   ),
                                  // ),
                                  child: CircleAvatar(
                                    radius: 60,
                                    backgroundImage: user?.avatar != null &&
                                            user!.avatar!.isNotEmpty
                                        ? CachedNetworkImageProvider(
                                            user.avatar!)
                                        : const NetworkImage(
                                            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=300',
                                          ) as ImageProvider,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // User Info
                      Text(
                        user?.fullName ?? 'NA',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '@${user?.username}',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          user?.bio ?? '',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            height: 1.4,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Stats Row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatItem(postsCnt.toString(), 'Posts'),
                            Container(
                              height: 40,
                              width: 1,
                              color: Colors.grey.shade300,
                            ),
                            _buildStatItem(
                                '${user?.followers?.length}', 'Followers'),
                            Container(
                              height: 40,
                              width: 1,
                              color: Colors.grey.shade300,
                            ),
                            _buildStatItem(
                                '${user?.following?.length}', 'Following'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Action Buttons

                      if (widget.uid !=
                              FirebaseAuth.instance.currentUser?.uid &&
                          widget.uid != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xffFF3131),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'Follow',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 3,
                                child: OutlinedButton(
                                  onPressed: () {},
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    side:
                                        BorderSide(color: Colors.grey.shade300),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    'Message',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.person_add_outlined),
                                  color: Colors.black,
                                  padding: const EdgeInsets.all(12),
                                  constraints: const BoxConstraints(),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 20),

                      // 🧭 Tab Bar
                      Container(
                        color: Colors.white,
                        child: TabBar(
                          dividerColor: AppColor.whiteColor,
                          controller: _tabController,
                          onTap: (index) {
                            setState(() => _currentIndex = index);
                          },
                          labelColor: const Color(0xffFF3131),
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: const Color(0xffFF3131),
                          tabs: const [
                            Tab(text: 'Posts'),
                            Tab(text: 'Media'),
                            Tab(text: 'About'),
                          ],
                        ),
                      ),

                      // 🔄 IndexedStack → conditional view by tab index
                      IndexedStack(
                        index: _currentIndex,
                        children: [
                          _buildPostsList(),
                          _buildMediaGrid(),
                          _buildAboutSection(user),
                        ],
                      ),
                    ],
                  ),
                );
              }),
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  // Tab 1: Posts List
  Widget _buildPostsList() {
    return Consumer(builder: (context, ref, _) {
      final postsAsync = ref.watch(userPostsProvider);

      return postsAsync.when(
          loading: () => AppLoader().loaderWidget(),
          error: (error, stack) => Center(child: Text('Error: $error')),
          data: (posts) {
            return ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8),
              shrinkWrap: true,
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return PostWidget(post: posts[index]);
              },
            );
          });
    });
  }

  // Tab 2: Media Grid
  Widget _buildMediaGrid() {
    return Consumer(builder: (context, ref, _) {
      final state = ref.watch(userPostsProvider);

      return state.when(
          data: (data) {
            final media =
                data.where((post) => post.type == PostType.image).toList();

            return Container(
              color: Colors.white,
              child: GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.all(5),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                ),
                itemCount: media.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {},
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(media[index].assets![0]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
          error: (err, st) => errorWidget(err, st),
          loading: () => AppLoader().loaderWidget());
    });
  }

  // Tab 3: About/Info Section
  Widget _buildAboutSection(User? user) {
    return Container(
      color: AppColor.whiteColor,
      child: ListView(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: const EdgeInsets.all(16),
        children: [
          sizeVer(10),
          // Overview Section
          _buildInfoCard(
            title: 'Overview',
            children: [
              _buildInfoRow(
                icon: Icons.cake_outlined,
                label: 'Birthday',
                value: TimeHelper.dobFormatter(
                    user?.dateOfBirth ?? Timestamp.now()),
              ),
              _buildInfoRow(
                icon: Icons.email_outlined,
                label: 'Email',
                value: user?.email ?? 'NA',
              ),
              // _buildInfoRow(
              //   icon: Icons.language_outlined,
              //   label: 'Website',
              //   value: 'www.akanetachi.com',
              // ),
            ],
          ),

          const SizedBox(height: 16),

          // Work & Education
          _buildInfoCard(
            title: 'Work & Education',
            children: [
              _buildInfoRow(
                icon: Icons.business_outlined,
                label: 'Works at',
                value: naStr(user?.profileHistory?.workspace),
              ),
              // _buildInfoRow(
              //   icon: Icons.work_outline,
              //   label: 'Position',
              //   value: 'Senior Photographer',
              // ),
              _buildInfoRow(
                icon: Icons.school_outlined,
                label: 'College',
                value: naStr(user?.profileHistory?.college),
              ),
              _buildInfoRow(
                icon: Icons.school_outlined,
                label: 'High School',
                value: naStr(user?.profileHistory?.school),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Location
          _buildInfoCard(
            title: 'Location',
            children: [
              _buildInfoRow(
                icon: Icons.location_on_outlined,
                label: 'City',
                value: naStr(user?.address?.city),
              ),
              _buildInfoRow(
                icon: Icons.home_outlined,
                label: 'State',
                value: naStr(user?.address?.state),
              ),
              _buildInfoRow(
                icon: Icons.home_outlined,
                label: 'Country',
                value: naStr(user?.address?.country),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // // Interests
          // _buildInfoCard(
          //   title: 'Interests',
          //   children: [
          //     _buildInfoRow(
          //       icon: Icons.favorite_outline,
          //       label: 'Hobbies',
          //       value: 'Photography, Travel, Art',
          //     ),
          //     _buildInfoRow(
          //       icon: Icons.music_note_outlined,
          //       label: 'Music',
          //       value: 'Jazz, Classical, Indie',
          //     ),
          //   ],
          // ),

          // const SizedBox(height: 16),

          // Social Links
          // _buildInfoCard(
          //   title: 'Social Links',
          //   children: [
          //     _buildInfoRow(
          //       icon: Icons.link,
          //       label: 'Instagram',
          //       value: '@akanetachi',
          //     ),
          //     _buildInfoRow(
          //       icon: Icons.link,
          //       label: 'Twitter',
          //       value: '@akanetachi',
          //     ),
          //     _buildInfoRow(
          //       icon: Icons.link,
          //       label: 'LinkedIn',
          //       value: 'Akane Tachibana',
          //     ),
          //   ],
          // ),
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: () => showEditProfileSheet(context, user!),
              child: Container(
                height: ScreenUtils().screenHeight(context) * 0.055,
                decoration: BoxDecoration(
                  color: AppColor.whiteColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColor.greyColor),
                ),
                child: Center(
                    child: Text(
                  'Update Profile',
                  style: appTextStyle(
                    color: AppColor.redColor,
                  ),
                )),
              ),
            ),
          ),
          sizeVer(10),
          Expanded(
            flex: 3,
            child: ElevatedButton(
              onPressed: () {
                ref.read(authFormProvider.notifier).logout();

                Navigator.pushNamedAndRemoveUntil(
                    context, RouteGenerator.kAuth, (r) => false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffFF3131),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Logout',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
      {required String title, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          ...children,
        ],
      ),
    );
  }

  void showEditProfileSheet(BuildContext context, User user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditProfileBottomSheet(user: user),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 22,
            color: const Color(0xffFF3131),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
