import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialseed/app/cubits/users/user_cubit.dart';
import 'package:socialseed/app/screens/user/user_profile.dart';
import 'package:socialseed/app/widgets/search_widget.dart';
import 'package:socialseed/domain/entities/user_entity.dart';

import '../../../utils/constants/color_const.dart';
import '../../../utils/constants/text_const.dart';

class SearchScreen extends StatefulWidget {
  final String currentUid;
  const SearchScreen({Key? key, required this.currentUid}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();

  List<UserEntity> users = [];
  List<UserEntity> filteredUsers = [];

  @override
  void initState() {
    super.initState();
    // Fetch users when the screen initializes
    context.read<UserCubit>().getUsers(user: const UserEntity());
  }

  void filterUsers(String query) {
    setState(() {
      filteredUsers = users.where((user) {
        final name = user.username!.toLowerCase();
        return name.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 60,
              margin: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: AppColor.greyColor,
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Image.asset(
                      'assets/icons/search.png',
                      color: AppColor.textGreyColor,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      onChanged: filterUsers,
                      controller: _controller,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search User',
                        hintStyle: TextConst.RegularStyle(
                          16,
                          AppColor.textGreyColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<UserCubit, UserState>(
                builder: (context, state) {
                  if (state is UserLoading) {
                    // Show loading indicator
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (state is UserLoaded) {
                    // Update users list when loaded
                    users = state.users;
                    return ListView.builder(
                      itemCount: filteredUsers.length,
                      itemBuilder: (ctx, idx) {
                        final user = filteredUsers[idx];

                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (ctx) =>
                                    UserProfile(otherUid: user.uid!),
                              ),
                            );
                          },
                          child: searchWidget(
                            filteredUsers[idx],
                          ),
                        );
                      },
                    );
                  } else if (state is UserFailure) {
                    // Show error message if failed to load users
                    return const Center(
                      child: Text('Failed to load users'),
                    );
                  }
                  // By default, return an empty container
                  return Container();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
