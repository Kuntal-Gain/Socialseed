import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socialseed/core/utils/constants/color_const.dart';
import 'package:socialseed/core/utils/helpers/app_loader.dart';
import 'package:socialseed/core/utils/helpers/failure_widget.dart';
import 'package:socialseed/core/utils/helpers/screen_utils.dart';
import 'package:socialseed/features/auth_module/model/user_model.dart';

import 'package:socialseed/features/friends_module/ui/providers/friend_module_provider.dart';

import 'provider/chat_provider.dart';

/// A screen to pick one or more users to start a new chat with.
/// Mirrors the style/colors of [FriendRequestsScreen].
class UserSelectionScreen extends ConsumerStatefulWidget {
  const UserSelectionScreen({super.key});

  @override
  ConsumerState<UserSelectionScreen> createState() =>
      _UserSelectionScreenState();
}

class _UserSelectionScreenState extends ConsumerState<UserSelectionScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  /// UIDs of currently selected users
  final Set<String> _selectedUids = {};

  bool _isStarting = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  List<User> _filter(List<User> users) {
    if (_query.isEmpty) return users;
    final q = _query.toLowerCase();
    return users
        .where((u) => (u.fullName ?? '').toLowerCase().contains(q))
        .toList();
  }

  void _toggleSelection(User user) {
    if (user.uid == null) return;
    setState(() {
      if (_selectedUids.contains(user.uid)) {
        _selectedUids.remove(user.uid);
      } else {
        _selectedUids.add(user.uid!);
      }
    });
  }

  Future<void> _startChat() async {
    if (_selectedUids.isEmpty) return;

    setState(() => _isStarting = true);

    // For each selected user, create (or fetch) a DM conversation.
    // Currently wires into ChatListNotifier.createConversation; extend
    // for group support as needed.
    for (final uid in _selectedUids) {
      await ref.read(chatListProvider.notifier).createConversation(uid);
    }

    setState(() => _isStarting = false);

    if (mounted) Navigator.pop(context);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final suggAsync = ref.watch(friendsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildSelectedChips(),
          Expanded(
            child: suggAsync.when(
              loading: () => AppLoader().stateLoader(),
              error: (err, st) => errorWidget(err, st,
                  onRefresh: () => ref.invalidate(suggestedUsersProvider)),
              data: (users) {
                final filtered = _filter(users);
                if (filtered.isEmpty) {
                  return _buildEmpty();
                }
                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) => _buildUserTile(filtered[i]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton:
          _selectedUids.isNotEmpty ? _buildStartChatFab() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // ── App bar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 16, color: Colors.black87),
        ),
      ),
      title: const Text(
        'New Message',
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: [
        if (_selectedUids.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: const BoxDecoration(
                  color: Color(0xffFF3131),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${_selectedUids.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ── Search bar — mirrors ChatListScreen ────────────────────────────────────

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(fontSize: 15),
              decoration: const InputDecoration(
                hintText: 'Search people...',
                border: InputBorder.none,
                isCollapsed: true,
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          if (_query.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() => _query = '');
              },
              child:
                  const Icon(Icons.close_rounded, color: Colors.grey, size: 18),
            ),
        ],
      ),
    );
  }

  // ── Selected user chips ────────────────────────────────────────────────────

  Widget _buildSelectedChips() {
    if (_selectedUids.isEmpty) return const SizedBox(height: 8);

    final suggAsync = ref.watch(suggestedUsersProvider);
    final allUsers = suggAsync.asData?.value ?? [];
    final selected =
        allUsers.where((u) => _selectedUids.contains(u.uid)).toList();

    return Container(
      height: 56,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: selected.length,
        itemBuilder: (context, i) {
          final user = selected[i];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Chip(
              avatar: CircleAvatar(
                backgroundColor: Colors.grey.shade200,
                backgroundImage:
                    (user.avatar != null && (user.avatar?.isNotEmpty ?? false))
                        ? NetworkImage(user.avatar!)
                        : null,
                child: (user.avatar == null || (user.avatar?.isEmpty ?? true))
                    ? Text(
                        (user.fullName ?? '?')[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xffFF3131),
                        ),
                      )
                    : null,
              ),
              label: Text(
                user.fullName?.split(' ').first ?? '',
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
              deleteIcon: const Icon(Icons.close_rounded, size: 16),
              onDeleted: () => _toggleSelection(user),
              backgroundColor: const Color(0xffFF3131).withOpacity(0.08),
              deleteIconColor: const Color(0xffFF3131),
              side: BorderSide(color: const Color(0xffFF3131).withOpacity(0.2)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
          );
        },
      ),
    );
  }

  // ── User tile — mirrors _buildSuggestionCard ───────────────────────────────

  Widget _buildUserTile(User user) {
    final isSelected = _selectedUids.contains(user.uid);

    return GestureDetector(
      onTap: () => _toggleSelection(user),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xffFF3131).withOpacity(0.04)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xffFF3131).withOpacity(0.3)
                : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: (user.avatar != null &&
                          (user.avatar?.isNotEmpty ?? false))
                      ? NetworkImage(user.avatar!)
                      : null,
                  child: (user.avatar == null || (user.avatar?.isEmpty ?? true))
                      ? Text(
                          (user.fullName ?? '?')[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xffFF3131),
                          ),
                        )
                      : null,
                ),
                if (isSelected)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Color(0xffFF3131),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_rounded,
                          size: 10, color: Colors.white),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // Name + username/bio
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName ?? '',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  if (user.username != null &&
                      (user.username?.isNotEmpty ?? false)) ...[
                    const SizedBox(height: 2),
                    Text(
                      '@${user.username}',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                ],
              ),
            ),

            // Select indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color:
                    isSelected ? const Color(0xffFF3131) : Colors.grey.shade100,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xffFF3131)
                      : Colors.grey.shade300,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty state ────────────────────────────────────────────────────────────

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Column(
        children: [
          Icon(Icons.person_search_rounded,
              size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'No users found',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ── FAB — mirrors ChatListScreen ───────────────────────────────────────────

  Widget _buildStartChatFab() {
    return FloatingActionButton.extended(
      backgroundColor: const Color(0xffFF3131),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onPressed: _isStarting ? null : _startChat,
      icon: _isStarting
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2),
            )
          : const Icon(Icons.send_rounded, color: Colors.white),
      label: Text(
        _selectedUids.length == 1 ? 'Start Chat' : 'Start Group Chat',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
