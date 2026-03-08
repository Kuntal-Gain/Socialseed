import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socialseed/core/provider/user_provider.dart';
import 'package:socialseed/core/services/route_generator.dart';
import 'package:socialseed/core/utils/constants/color_const.dart';
import 'package:socialseed/core/utils/helpers/app_loader.dart';
import 'package:socialseed/core/utils/helpers/appbar.dart';
import 'package:socialseed/core/utils/helpers/failure_widget.dart';
import 'package:socialseed/core/utils/helpers/no_data_found_widget.dart';
import 'package:socialseed/core/utils/helpers/screen_utils.dart';
import 'package:socialseed/core/utils/helpers/scroll_view.dart';
import 'package:socialseed/features/auth_module/ui/provider/creds_provider.dart';
import 'package:socialseed/features/chat/model/chat_model.dart';
import 'package:socialseed/features/chat/ui/user_selection_screen.dart';

import 'provider/chat_provider.dart';

// ── Screen ─────────────────────────────────────────────────────────────────────
class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatTime(int timestamp) {
    final time = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays == 1) return 'Yesterday';
    return '${time.day}/${time.month}/${time.year}';
  }

  /// Returns the peer's display name from a DM chat.
  /// For groups, you'd want to return the group name instead.
  String _getChatName(ChatModel chat, String currentUid) {
    if (chat.type == ChatType.dm) {
      final peerId = chat.participants.keys
          .firstWhere((id) => id != currentUid, orElse: () => '');
      return peerId.isNotEmpty ? peerId : 'Unknown';
    }
    return 'Group Chat';
  }

  /// Returns the peer's UID for DMs.
  String _getPeerUid(ChatModel chat, String currentUid) {
    if (chat.type == ChatType.dm) {
      return chat.participants.keys
          .firstWhere((id) => id != currentUid, orElse: () => '');
    }
    return '';
  }

  int _getUnreadCount(ChatModel chat, String currentUid) {
    return chat.unreadCount[currentUid] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final chatListAsync = ref.watch(chatListProvider);

    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: CommonAppbar(title: "Messages"),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(chatListProvider);
        },
        child: CommonScreenWrapper(
          containsScrollable: true,
          body: SafeArea(
            child: chatListAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Text(
                  'Something went wrong.\n$err',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
              data: (chats) {
                final filtered = _searchQuery.isEmpty
                    ? chats
                    : chats
                        .where((c) => c.lastMessage.text
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase()))
                        .toList();

                return Column(
                  children: [
                    // _buildHeader(context),
                    const SizedBox(height: 10),
                    _buildSearchBar(),
                    const SizedBox(height: 10),
                    _buildChatList(filtered),
                  ],
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: _buildNewChatFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
      child: Row(
        children: [
          GestureDetector(
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
          sizeHor(12),
          Expanded(
            child: Text(
              'Messages',
              style: TextStyle(
                fontSize: ScreenUtils().screenHeight(context) * 0.032,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: -0.5,
              ),
            ),
          ),
          _iconBtn(
            icon: Icons.person_add_alt_1_outlined,
            onTap: () {},
          ),
          const SizedBox(width: 8),
          _iconBtn(
            icon: Icons.more_horiz_rounded,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _iconBtn({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
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
        child: Icon(icon, size: 20, color: Colors.black87),
      ),
    );
  }

  // ── Search bar ────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
                hintText: 'Search messages...',
                border: InputBorder.none,
                isCollapsed: true,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
              child:
                  const Icon(Icons.close_rounded, color: Colors.grey, size: 18),
            )
          else
            const Icon(Icons.tune_rounded, color: Colors.grey),
        ],
      ),
    );
  }

  // ── Chat list ──────────────────────────────────────────────────────────────
  Widget _buildChatList(List<ChatModel> chats) {
    if (chats.isEmpty) {
      return NoDataFoundWidget(
        title: 'No conversations found',
        message: 'Start a new chat to begin messaging',
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: chats.length,
      padding: const EdgeInsets.only(bottom: 80),
      itemBuilder: (context, index) => _chatTile(chats[index]),
    );
  }

  Widget _chatTile(ChatModel chat) {
    // TODO: replace with real currentUid from auth provider

    final myUid = FirebaseAuth.instance.currentUser?.uid;

    final otherUid = chat.participants.keys.firstWhere(
      (uid) => uid != myUid,
    );

    final userAsync = ref.watch(userByIdProvider(otherUid));

    final hasUnread = (chat.unreadCount[myUid] ?? 0) > 0;
    final count = chat.unreadCount[myUid] ?? 0;
    final lastMsg = chat.lastMessage;

    return GestureDetector(
      onTap: () => _openChat(chat),
      child: userAsync.when(
          loading: () => AppLoader().stateLoader(),
          error: (error, stack) => errorWidget(error, stack),
          data: (user) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: hasUnread
                    ? const Color(0xffFF3131).withOpacity(0.04)
                    : Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Avatar — initials from chatName
                  _avatar(user?.avatar ?? user?.fullName ?? '', radius: 26),
                  const SizedBox(width: 12),

                  // Name + last message
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.fullName ?? '',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight:
                                hasUnread ? FontWeight.w700 : FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          lastMsg.text.isNotEmpty ? lastMsg.text : '...',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: hasUnread
                                ? Colors.black87
                                : Colors.grey.shade500,
                            fontWeight:
                                hasUnread ? FontWeight.w500 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Time + unread badge
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatTime(lastMsg.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: hasUnread
                              ? const Color(0xffFF3131)
                              : Colors.grey.shade400,
                          fontWeight:
                              hasUnread ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 5),
                      if (hasUnread)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xffFF3131),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            count > 9 ? '9+' : '$count',
                            style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.w700),
                          ),
                        )
                      else
                        Icon(
                          Icons.done_all_rounded,
                          size: 16,
                          color: const Color(0xffFF3131).withOpacity(0.5),
                        ),
                    ],
                  ),
                ],
              ),
            );
          }),
    );
  }

  // ── Avatar (initials only — no avatarUrl in ChatModel) ────────────────────
  Widget _avatar(String name, {required double radius}) {
    bool isUrl = name.contains(".");

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey.shade200,
      backgroundImage: isUrl ? NetworkImage(name) : null,
      child: isUrl
          ? null
          : Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(
                fontSize: radius * 0.8,
                fontWeight: FontWeight.w700,
                color: const Color(0xffFF3131),
              ),
            ),
    );
  }

  // ── FAB ───────────────────────────────────────────────────────────────────
  Widget _buildNewChatFab() {
    return FloatingActionButton.extended(
      backgroundColor: Colors.redAccent,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      onPressed: () {
        // TODO: Navigate to new chat / user search

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => UserSelectionScreen(),
          ),
        );
      },
      icon: const Icon(Icons.edit_outlined, color: Colors.white),
      label: const Text(
        'New Chat',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _openChat(ChatModel chat) {
    ref.read(selectedConversationProvider.notifier).state = chat;

    Navigator.pushNamed(
      context,
      RouteGenerator.kMessage,
    );
  }
}
