import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socialseed/core/utils/constants/color_const.dart';
import 'package:socialseed/core/utils/helpers/app_loader.dart';
import 'package:socialseed/core/utils/helpers/failure_widget.dart';
import 'package:socialseed/core/utils/helpers/screen_utils.dart';
import 'package:socialseed/features/auth_module/data/auth/auth_usecase.dart';
import 'package:socialseed/core/network/locator.dart';
import 'package:socialseed/features/auth_module/ui/provider/creds_provider.dart';
import 'package:socialseed/features/chat/model/chat_model.dart';

import '../../auth_module/model/user_model.dart';
import 'provider/chat_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Design tokens
// ─────────────────────────────────────────────────────────────────────────────

class _C {
  static const bg = Color(0xffF4F6FA);
  static const surface = Color(0xffFFFFFF);
  static const surfaceUp = Color(0xffF0F2F8);
  static const surfaceGlass = Color(0x14000000);
  static const red = Color(0xffFF3131);
  static const redB = Color(0xffFF6B35);
  static const redGlow = Color(0x28FF3131);
  static const redSoft = Color(0x0DFF3131);
  static const textPri = Color(0xff0F0F14);
  static const textSec = Color(0xff7A7A8A);
  static const textMut = Color(0xffBBBBC8);
  static const border = Color(0xffE8EAF0);
  static const green = Color(0xff10B981);
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen — reads everything from providers, no constructor args needed
// ─────────────────────────────────────────────────────────────────────────────

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with TickerProviderStateMixin {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final _focus = FocusNode();

  bool _typing = false;
  bool _showAttach = false;
  MessageModel? _replyTo;

  // Resolved once from route args
  String _peerUid = '';
  String _peerName = '';
  String _peerAvatar = '';
  String _chatId = '';

  String? _currentUid;

  late final AnimationController _sendPulse;
  late final Animation<double> _sendScale;
  late final AnimationController _attachAnim;
  late final Animation<Offset> _attachSlide;
  late final Animation<double> _attachFade;

  @override
  void initState() {
    super.initState();
    _sendPulse = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 130));
    _sendScale = Tween<double>(begin: 1.0, end: 0.86)
        .animate(CurvedAnimation(parent: _sendPulse, curve: Curves.easeInOut));

    _attachAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 260));
    _attachSlide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _attachAnim, curve: Curves.easeOutCubic));
    _attachFade = CurvedAnimation(parent: _attachAnim, curve: Curves.easeOut);

    _ctrl.addListener(() {
      final t = _ctrl.text.trim().isNotEmpty;
      if (t != _typing) setState(() => _typing = t);
    });

    _loadCurrentUid();
  }

  Future<void> _loadCurrentUid() async {
    _currentUid = await getIt<AuthUsecases>().getCurrentUid();
    if (mounted) setState(() {});
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   final args =
  //       ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
  //   if (args != null) {
  //     _chatId = args['chatId'] ?? '';
  //     _peerUid = args['peerUid'] ?? '';
  //     _peerName = args['peerName'] ?? '';
  //     _peerAvatar = args['peerAvatar'] ?? '';

  //     // Set the active conversation so messageProvider starts streaming
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       ref.read(selectedConversationProvider.notifier).state = _chatId;
  //     });
  //   }
  // }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    _focus.dispose();
    _sendPulse.dispose();
    _attachAnim.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  bool _isMe(String senderId) => senderId == _currentUid;

  void _scrollBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic);
      }
    });
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _currentUid == null) return;

    await _sendPulse.forward();
    await _sendPulse.reverse();
    HapticFeedback.lightImpact();

    final msg = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: _currentUid!,
      type: MessageType.text,
      text: text,
      assets: [],
      readBy: {_currentUid!: true},
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    _ctrl.clear();
    setState(() => _replyTo = null);

    await ref.read(messageProvider.notifier).sendMessage(msg);
    _scrollBottom();
  }

  void _toggleAttach() {
    setState(() => _showAttach = !_showAttach);
    _showAttach ? _attachAnim.forward() : _attachAnim.reverse();
    if (_showAttach) _focus.unfocus();
  }

  String _fmtTime(int timestamp) {
    final t = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m ${t.hour >= 12 ? 'PM' : 'AM'}';
  }

  String _fmtDiv(DateTime t) {
    final n = DateTime.now();
    if (t.day == n.day && t.month == n.month && t.year == n.year)
      return 'Today';
    final y = n.subtract(const Duration(days: 1));
    if (t.day == y.day && t.month == y.month && t.year == y.year)
      return 'Yesterday';
    return '${t.day}/${t.month}/${t.year}';
  }

  bool _needsDiv(List<MessageModel> msgs, int i) {
    if (i == 0) return true;
    final a = DateTime.fromMillisecondsSinceEpoch(msgs[i].createdAt);
    final b = DateTime.fromMillisecondsSinceEpoch(msgs[i - 1].createdAt);
    return a.day != b.day || a.month != b.month || a.year != b.year;
  }

  bool _isRead(MessageModel msg) {
    // A message is "read" if the peer has an entry in readBy
    return msg.readBy[_peerUid] == true;
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final chat = ref.watch(selectedConversationProvider);
    final msgsAsync = ref.watch(messageProvider);
    final kb = MediaQuery.of(context).viewInsets.bottom;

    print(chat?.toMap());

    final myUid = FirebaseAuth.instance.currentUser?.uid;

    final otherUid = chat?.participants.keys.firstWhere(
      (uid) => uid != myUid,
    );

    final userAsync = ref.watch(userByIdProvider(otherUid!));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _C.surface,
        body: userAsync.when(
            loading: () => AppLoader().stateLoader(),
            error: (e, s) => errorWidget(e, s),
            data: (user) {
              return Stack(children: [
                // Background glow orbs
                Positioned(
                  top: -100,
                  right: -80,
                  child: Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [
                        _C.red.withOpacity(0.05),
                        Colors.transparent
                      ]),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 200,
                  left: -60,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [
                        const Color(0xff6C63FF).withOpacity(0.05),
                        Colors.transparent,
                      ]),
                    ),
                  ),
                ),

                SafeArea(
                  top: false,
                  child: Column(children: [
                    _appBar(user),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _focus.unfocus();
                          if (_showAttach) {
                            setState(() => _showAttach = false);
                            _attachAnim.reverse();
                          }
                        },
                        child: msgsAsync.when(
                          loading: () => const Center(
                              child: CircularProgressIndicator(
                                  color: _C.red, strokeWidth: 1.5)),
                          error: (e, s) => Center(
                              child: Text('Failed to load',
                                  style: TextStyle(color: _C.textMut))),
                          data: (msgs) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (_scroll.hasClients)
                                _scroll
                                    .jumpTo(_scroll.position.maxScrollExtent);
                            });

                            if (msgs.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.chat_bubble_outline_rounded,
                                        size: 48, color: _C.textMut),
                                    const SizedBox(height: 12),
                                    const Text('No messages yet. Say hi! 👋',
                                        style: TextStyle(
                                            color: _C.textSec, fontSize: 14)),
                                  ],
                                ),
                              );
                            }

                            return ListView.builder(
                              controller: _scroll,
                              padding:
                                  const EdgeInsets.fromLTRB(14, 10, 14, 14),
                              itemCount: msgs.length,
                              itemBuilder: (_, i) {
                                final msg = msgs[i];
                                final tail = i == msgs.length - 1 ||
                                    msgs[i + 1].senderId != msg.senderId;
                                return Column(children: [
                                  if (_needsDiv(msgs, i))
                                    _divider(_fmtDiv(
                                        DateTime.fromMillisecondsSinceEpoch(
                                            msg.createdAt))),
                                  _msgRow(msg, tail, user),
                                ]);
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    if (_replyTo != null) _replyBanner(),
                    if (_showAttach) _attachTray(),
                    _inputBar(kb),
                  ]),
                ),
              ]);
            }),
      ),
    );
  }

  // ── App bar ────────────────────────────────────────────────────────────────

  Widget _appBar(User? other) {
    // FIX: Wrap in SizedBox with explicit width to give ClipRect/BackdropFilter
    // a proper layout constraint, preventing "RenderBox was not laid out" errors.
    return SizedBox(
      width: double.infinity,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(8, 10, 12, 12),
            decoration: BoxDecoration(
              color: AppColor.redColor,
              border: const Border(
                  bottom: BorderSide(color: _C.border, width: 0.5)),
            ),
            child: Column(
              children: [
                sizeVer(20),
                Row(children: [
                  _glassBtn(
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 15, color: _C.surface),
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 10),
                  _peerRing(other?.avatar, other?.fullName ?? 'Unknown'),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(other?.fullName ?? "Unknown",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: _C.surface,
                                letterSpacing: -0.4,
                              )),
                          const SizedBox(height: 2),
                          Text(
                            'Last seen recently',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Colors.grey.shade100,
                            ),
                          ),
                        ]),
                  ),
                  _glassBtn(
                      child: const Icon(Icons.videocam_outlined,
                          size: 18, color: _C.surface),
                      onTap: () {}),
                  const SizedBox(width: 6),
                  _glassBtn(
                      child: const Icon(Icons.call_outlined,
                          size: 18, color: _C.surface),
                      onTap: () {}),
                  const SizedBox(width: 6),
                  _glassBtn(
                      child: const Icon(Icons.more_horiz_rounded,
                          size: 18, color: _C.surface),
                      onTap: _moreSheet),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _glassBtn({required Widget child, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.7),
                width: 1.2,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _peerRing(String? avatar, String fallback) {
    return SizedBox(
      width: 44,
      height: 44,
      child: CircleAvatar(
        radius: 22,
        backgroundColor: _C.surfaceUp,
        backgroundImage: avatar != null ? NetworkImage(avatar) : null,
        child: avatar == null
            ? Text(fallback.split('').map((e) => e[0]).join(''),
                style: const TextStyle(
                    fontWeight: FontWeight.w800, color: _C.red, fontSize: 17))
            : null,
      ),
    );
  }

  // ── Date divider ───────────────────────────────────────────────────────────

  Widget _divider(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(children: [
        Expanded(child: Container(height: 0.5, color: _C.border)),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: _C.surfaceUp,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _C.border, width: 0.5),
          ),
          child: Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  color: _C.textSec,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.4)),
        ),
        Expanded(child: Container(height: 0.5, color: _C.border)),
      ]),
    );
  }

  // ── Message row ────────────────────────────────────────────────────────────

  Widget _msgRow(MessageModel msg, bool tail, User? user) {
    final isMe = _isMe(msg.senderId);
    return Padding(
      padding: EdgeInsets.only(
        bottom: tail ? 10 : 2,
        left: isMe ? 52 : 0,
        right: isMe ? 0 : 52,
      ),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            if (tail)
              CircleAvatar(
                radius: 14,
                backgroundColor: _C.surfaceUp,
                backgroundImage: user?.avatar != null
                    ? NetworkImage(user?.avatar ?? "")
                    : null,
                child: user?.avatar == null
                    ? Text(
                        (user?.fullName ?? "")
                            .split('')
                            .map((e) => e[0].toUpperCase())
                            .join(''),
                        style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: _C.red))
                    : null,
              )
            else
              const SizedBox(width: 28),
            const SizedBox(width: 7),
          ],
          GestureDetector(
            onLongPress: () {
              HapticFeedback.mediumImpact();
              _msgSheet(msg);
            },
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.70),
              child: _bubble(msg),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bubble(MessageModel msg) {
    final isMe = _isMe(msg.senderId);
    final isDeleted = msg.type == MessageType.system && msg.text.isEmpty;

    if (isDeleted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: _C.surfaceUp,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _C.border, width: 0.5),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.block_rounded, size: 13, color: _C.textMut),
          const SizedBox(width: 6),
          Text(isMe ? 'You deleted this message' : 'Message deleted',
              style: const TextStyle(
                  fontSize: 13,
                  color: _C.textMut,
                  fontStyle: FontStyle.italic)),
        ]),
      );
    }

    final br = BorderRadius.only(
      topLeft: const Radius.circular(20),
      topRight: const Radius.circular(20),
      bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(5),
      bottomRight: isMe ? const Radius.circular(5) : const Radius.circular(20),
    );

    // Image message
    final imageAsset = msg.assets.isNotEmpty && msg.type == MessageType.image
        ? msg.assets.first
        : null;

    return Container(
      decoration: BoxDecoration(
        gradient: isMe
            ? const LinearGradient(
                colors: [_C.red, _C.redB],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight)
            : null,
        color: isMe ? null : _C.surfaceUp,
        borderRadius: br,
        border: isMe ? null : Border.all(color: _C.border, width: 0.5),
        boxShadow: isMe
            ? [
                BoxShadow(
                    color: _C.red.withOpacity(0.28),
                    blurRadius: 18,
                    offset: const Offset(0, 7))
              ]
            : [
                BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 10,
                    offset: const Offset(0, 3))
              ],
      ),
      child: ClipRRect(
        borderRadius: br,
        child: Stack(children: [
          if (isMe)
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.07),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(13, 10, 11, 8),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              // Image attachment
              if (imageAsset != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(imageAsset.url,
                      width: 220, fit: BoxFit.cover),
                ),

              // Text
              if (msg.text.isNotEmpty)
                Text(msg.text,
                    style: TextStyle(
                      fontSize: 14.5,
                      height: 1.45,
                      letterSpacing: 0.05,
                      color: isMe ? Colors.white : _C.textPri,
                    )),

              const SizedBox(height: 4),

              // Time + read ticks
              Row(mainAxisSize: MainAxisSize.min, children: [
                Text(_fmtTime(msg.createdAt),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: isMe ? Colors.white.withOpacity(0.6) : _C.textSec,
                    )),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    _isRead(msg) ? Icons.done_all_rounded : Icons.done_rounded,
                    size: 13,
                    color: _isRead(msg)
                        ? Colors.white
                        : Colors.white.withOpacity(0.45),
                  ),
                ],
              ]),
            ]),
          ),
        ]),
      ),
    );
  }

  // ── Reply banner ───────────────────────────────────────────────────────────

  Widget _replyBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 4),
      padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
      decoration: BoxDecoration(
        color: _C.surfaceUp,
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(color: _C.red, width: 3),
          top: BorderSide(color: _C.border, width: 0.5),
          right: BorderSide(color: _C.border, width: 0.5),
          bottom: BorderSide(color: _C.border, width: 0.5),
        ),
      ),
      child: Row(children: [
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_isMe(_replyTo!.senderId) ? 'You' : _peerName,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: _C.red)),
          const SizedBox(height: 2),
          Text(_replyTo!.text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: _C.textSec)),
        ])),
        GestureDetector(
          onTap: () => setState(() => _replyTo = null),
          child: const Icon(Icons.close_rounded, size: 17, color: _C.textSec),
        ),
      ]),
    );
  }

  // ── Attach tray ────────────────────────────────────────────────────────────

  Widget _attachTray() {
    final items = [
      (Icons.image_outlined, 'Gallery', const Color(0xff6C63FF)),
      (Icons.camera_alt_outlined, 'Camera', const Color(0xff00C9A7)),
      (Icons.insert_drive_file_outlined, 'File', const Color(0xffFF9F43)),
      (Icons.location_on_outlined, 'Location', _C.red),
      (Icons.contact_page_outlined, 'Contact', const Color(0xff2EC4B6)),
    ];
    return FadeTransition(
      opacity: _attachFade,
      child: SlideTransition(
        position: _attachSlide,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
          decoration: const BoxDecoration(
            color: _C.surface,
            border: Border(top: BorderSide(color: _C.border, width: 0.5)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.map((e) => _attachItem(e.$1, e.$2, e.$3)).toList(),
          ),
        ),
      ),
    );
  }

  Widget _attachItem(IconData icon, String label, Color color) {
    return GestureDetector(
      onTap: () async {
        if (icon == Icons.image_outlined) {
          _toggleAttach();
          await ImagePicker()
              .pickImage(source: ImageSource.gallery, imageQuality: 80);
        } else if (icon == Icons.camera_alt_outlined) {
          _toggleAttach();
          await ImagePicker()
              .pickImage(source: ImageSource.camera, imageQuality: 80);
        } else {
          _toggleAttach();
        }
      },
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: color.withOpacity(0.11),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.22), width: 0.5),
          ),
          child: Icon(icon, color: color, size: 23),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: _C.textSec, fontWeight: FontWeight.w500)),
      ]),
    );
  }

  // ── Input bar ──────────────────────────────────────────────────────────────

  Widget _inputBar(double kb) {
    return Container(
      padding: EdgeInsets.fromLTRB(12, 10, 12, 10 + kb),
      decoration: const BoxDecoration(
        color: _C.surface,
        border: Border(top: BorderSide(color: _C.border, width: 0.5)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        GestureDetector(
          onTap: _toggleAttach,
          child: SizedBox(
            width: 44,
            height: 44,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              decoration: BoxDecoration(
                gradient: _showAttach
                    ? const LinearGradient(
                        colors: [_C.red, _C.redB],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight)
                    : null,
                color: _showAttach ? null : _C.surfaceUp,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                    color: _showAttach ? Colors.transparent : _C.border,
                    width: 0.5),
                boxShadow: _showAttach
                    ? [
                        BoxShadow(
                            color: _C.red.withOpacity(0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4))
                      ]
                    : null,
              ),
              child: Icon(
                _showAttach ? Icons.close_rounded : Icons.add_rounded,
                size: 21,
                color: _showAttach ? Colors.white : _C.textPri,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            constraints: const BoxConstraints(minHeight: 44),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: _C.surfaceUp,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: _C.border, width: 0.5),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  focusNode: _focus,
                  maxLines: 5,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  style: const TextStyle(
                      fontSize: 14.5, color: _C.textPri, height: 1.4),
                  cursorColor: _C.red,
                  decoration: const InputDecoration(
                    hintText: 'Message...',
                    hintStyle: TextStyle(color: _C.textMut, fontSize: 14.5),
                    border: InputBorder.none,
                    isCollapsed: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 9),
                  ),
                ),
              ),
              if (!_typing)
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 7),
                  child: Icon(Icons.emoji_emotions_outlined,
                      size: 20, color: _C.textSec),
                ),
            ]),
          ),
        ),
        const SizedBox(width: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 230),
          transitionBuilder: (child, anim) => ScaleTransition(
            scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
            child: child,
          ),
          child: _typing
              ? ScaleTransition(
                  key: const ValueKey('send'),
                  scale: _sendScale,
                  child: GestureDetector(
                    onTap: _send,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_C.red, _C.redB],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(13),
                        boxShadow: [
                          BoxShadow(
                              color: _C.red.withOpacity(0.45),
                              blurRadius: 16,
                              offset: const Offset(0, 6)),
                        ],
                      ),
                      child: const Icon(Icons.send_rounded,
                          size: 18, color: Colors.white),
                    ),
                  ),
                )
              : GestureDetector(
                  key: const ValueKey('mic'),
                  onTap: () {},
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _C.surfaceUp,
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(color: _C.border, width: 0.5),
                    ),
                    child: const Icon(Icons.mic_none_rounded,
                        size: 20, color: _C.textPri),
                  ),
                ),
        ),
      ]),
    );
  }

  // ── Bottom sheets ──────────────────────────────────────────────────────────

  void _msgSheet(MessageModel msg) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _C.surfaceUp,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 8),
          Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: _C.textMut, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 6),
          _sheetTile(Icons.reply_rounded, 'Reply', _C.textPri, () {
            Navigator.pop(context);
            setState(() => _replyTo = msg);
            _focus.requestFocus();
          }),
          _sheetTile(Icons.copy_rounded, 'Copy text', _C.textPri, () {
            Navigator.pop(context);
            Clipboard.setData(ClipboardData(text: msg.text));
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Text('Copied to clipboard'),
              backgroundColor: _C.red,
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ));
          }),
          if (_isMe(msg.senderId))
            _sheetTile(
                Icons.delete_outline_rounded, 'Delete', const Color(0xffFF4757),
                () async {
              Navigator.pop(context);
              await ref.read(messageProvider.notifier).deleteMessage(msg.id);
            }),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  Widget _sheetTile(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
      title: Text(label,
          style: TextStyle(
              color: color, fontSize: 14, fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }

  void _moreSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _C.surfaceUp,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 8),
          Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: _C.textMut, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 6),
          _sheetTile(Icons.search_rounded, 'Search in chat', _C.textPri,
              () => Navigator.pop(context)),
          _sheetTile(Icons.notifications_off_outlined, 'Mute notifications',
              _C.textPri, () => Navigator.pop(context)),
          _sheetTile(Icons.person_outline_rounded, 'View profile', _C.textPri,
              () => Navigator.pop(context)),
          _sheetTile(Icons.cleaning_services_outlined, 'Clear chat',
              const Color(0xffFF9F43), () async {
            Navigator.pop(context);
            await ref.read(messageProvider.notifier).clearChat();
          }),
          _sheetTile(Icons.block_rounded, 'Block user', const Color(0xffFF4757),
              () => Navigator.pop(context)),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }
}
