import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────
//  Models
// ─────────────────────────────────────────────────────────────
class SearchResult {
  final String id;
  final String title;
  final String subtitle;
  final String? avatarUrl;
  final SearchResultType type;

  const SearchResult({
    required this.id,
    required this.title,
    required this.subtitle,
    this.avatarUrl,
    required this.type,
  });
}

enum SearchResultType { user, post, tag, location }

// ─── Mock data – replace with your real provider ─────────────
final _mockResults = [
  SearchResult(
    id: '1',
    title: 'Sarah Johnson',
    subtitle: '12.4K followers',
    avatarUrl:
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
    type: SearchResultType.user,
  ),
  SearchResult(
    id: '2',
    title: 'Michael Chen',
    subtitle: '8.9K followers',
    avatarUrl:
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
    type: SearchResultType.user,
  ),
  SearchResult(
    id: '3',
    title: '#travel',
    subtitle: '2.3M posts',
    type: SearchResultType.tag,
  ),
  SearchResult(
    id: '4',
    title: '#nature',
    subtitle: '1.8M posts',
    type: SearchResultType.tag,
  ),
  SearchResult(
    id: '5',
    title: 'Yosemite National Park',
    subtitle: 'California, USA',
    type: SearchResultType.location,
  ),
  SearchResult(
    id: '6',
    title: 'Emily Davis',
    subtitle: '5.1K followers',
    avatarUrl:
        'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150',
    type: SearchResultType.user,
  ),
  SearchResult(
    id: '7',
    title: '#food',
    subtitle: '3.4M posts',
    type: SearchResultType.tag,
  ),
  SearchResult(
    id: '8',
    title: 'Paris, France',
    subtitle: 'Île-de-France, France',
    type: SearchResultType.location,
  ),
];

final _recentSearches = ['#travel', 'Sarah Johnson', 'Yosemite', '#food'];

// ─────────────────────────────────────────────────────────────
//  ExploreSearchBar  –  the tappable bar on your explore screen
// ─────────────────────────────────────────────────────────────
class ExploreSearchBar extends StatelessWidget {
  const ExploreSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openOverlay(context),
      child: Hero(
        tag: 'search_bar',
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.grey.shade600, size: 20),
                const SizedBox(width: 10),
                Text(
                  'Search',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openOverlay(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: false,
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (_, __, ___) => const SearchOverlayScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: child,
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  SearchOverlayScreen  –  full screen transparent overlay
// ─────────────────────────────────────────────────────────────
class SearchOverlayScreen extends StatefulWidget {
  const SearchOverlayScreen({super.key});

  @override
  State<SearchOverlayScreen> createState() => _SearchOverlayScreenState();
}

class _SearchOverlayScreenState extends State<SearchOverlayScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _ctrl = TextEditingController();
  final FocusNode _focus = FocusNode();
  List<SearchResult> _results = [];
  bool _hasQuery = false;

  late AnimationController _staggerCtrl;

  @override
  void initState() {
    super.initState();
    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();

    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
    _ctrl.addListener(_onSearch);
  }

  void _onSearch() {
    final q = _ctrl.text.trim().toLowerCase();
    setState(() {
      _hasQuery = q.isNotEmpty;
      _results = q.isEmpty
          ? []
          : _mockResults
              .where((r) =>
                  r.title.toLowerCase().contains(q) ||
                  r.subtitle.toLowerCase().contains(q))
              .toList();
    });
    if (_results.isNotEmpty) _staggerCtrl.forward(from: 0);
  }

  void _close() {
    _focus.unfocus();
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    _staggerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fully transparent black tint – the screen behind bleeds through
      backgroundColor: Colors.black.withOpacity(0.65),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top search bar ─────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Hero(
                      tag: 'search_bar',
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 4),
                          child: Row(
                            children: [
                              Icon(Icons.search,
                                  color: Colors.grey.shade500, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _ctrl,
                                  focusNode: _focus,
                                  style: const TextStyle(
                                      fontSize: 15, color: Colors.black87),
                                  decoration: InputDecoration(
                                    hintText: 'Search people, tags, places…',
                                    hintStyle: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontSize: 15),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                  ),
                                  textInputAction: TextInputAction.search,
                                ),
                              ),
                              if (_ctrl.text.isNotEmpty)
                                GestureDetector(
                                  onTap: _ctrl.clear,
                                  child: Icon(Icons.cancel,
                                      color: Colors.grey.shade400, size: 18),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _close,
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Body ──────────────────────────────────────
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _hasQuery
                    ? _ResultsList(
                        key: const ValueKey('results'),
                        results: _results,
                        query: _ctrl.text,
                        staggerCtrl: _staggerCtrl,
                      )
                    : _RecentSection(
                        key: const ValueKey('recent'),
                        staggerCtrl: _staggerCtrl,
                        onTap: (s) {
                          _ctrl.text = s;
                          _ctrl.selection = TextSelection.fromPosition(
                            TextPosition(offset: s.length),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  _ResultsList
// ─────────────────────────────────────────────────────────────
class _ResultsList extends StatelessWidget {
  final List<SearchResult> results;
  final String query;
  final AnimationController staggerCtrl;

  const _ResultsList({
    super.key,
    required this.results,
    required this.query,
    required this.staggerCtrl,
  });

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 48, color: Colors.white38),
            const SizedBox(height: 12),
            Text(
              'No results for "$query"',
              style: const TextStyle(color: Colors.white54, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: results.length,
      itemBuilder: (ctx, i) {
        final itemDelay = i * 0.07;
        return AnimatedBuilder(
          animation: staggerCtrl,
          builder: (_, child) {
            final t = Curves.easeOut.transform(
              ((staggerCtrl.value - itemDelay) / (1.0 - itemDelay))
                  .clamp(0.0, 1.0),
            );
            return Opacity(
              opacity: t,
              child: Transform.translate(
                offset: Offset(0, 16 * (1 - t)),
                child: child,
              ),
            );
          },
          child: _ResultTile(result: results[i], query: query),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  _ResultTile
// ─────────────────────────────────────────────────────────────
class _ResultTile extends StatelessWidget {
  final SearchResult result;
  final String query;

  const _ResultTile({required this.result, required this.query});

  IconData get _typeIcon {
    switch (result.type) {
      case SearchResultType.user:
        return Icons.person_outline;
      case SearchResultType.tag:
        return Icons.tag;
      case SearchResultType.location:
        return Icons.location_on_outlined;
      default:
        return Icons.search;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(12),
      splashColor: Colors.white10,
      highlightColor: Colors.white10,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            _buildLeading(),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HighlightedText(
                    text: result.title,
                    highlight: query,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    highlightStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xffFF3131),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    result.subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.white54),
                  ),
                ],
              ),
            ),
            const Icon(Icons.north_west, size: 14, color: Colors.white24),
          ],
        ),
      ),
    );
  }

  Widget _buildLeading() {
    if (result.type == SearchResultType.user && result.avatarUrl != null) {
      return CircleAvatar(
        radius: 22,
        backgroundColor: Colors.white12,
        backgroundImage: NetworkImage(result.avatarUrl!),
      );
    }
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        color: Colors.white12,
        shape: BoxShape.circle,
      ),
      child: Icon(_typeIcon, color: Colors.white70, size: 20),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  _RecentSection
// ─────────────────────────────────────────────────────────────
class _RecentSection extends StatelessWidget {
  final AnimationController staggerCtrl;
  final ValueChanged<String> onTap;

  const _RecentSection({
    super.key,
    required this.staggerCtrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        const Text(
          'RECENT',
          style: TextStyle(
            color: Colors.white38,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        ..._recentSearches.asMap().entries.map((entry) {
          final i = entry.key;
          final s = entry.value;
          final delay = i * 0.08;
          return AnimatedBuilder(
            animation: staggerCtrl,
            builder: (_, child) {
              final t = Curves.easeOut.transform(
                ((staggerCtrl.value - delay) / (1.0 - delay)).clamp(0.0, 1.0),
              );
              return Opacity(
                opacity: t,
                child: Transform.translate(
                    offset: Offset(0, 12 * (1 - t)), child: child),
              );
            },
            child: InkWell(
              onTap: () => onTap(s),
              borderRadius: BorderRadius.circular(10),
              splashColor: Colors.white10,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                child: Row(
                  children: [
                    const Icon(Icons.history, color: Colors.white38, size: 20),
                    const SizedBox(width: 14),
                    Text(
                      s,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                    ),
                    const Spacer(),
                    const Icon(Icons.north_west,
                        size: 14, color: Colors.white24),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 32),
        const Text(
          'SUGGESTED',
          style: TextStyle(
            color: Colors.white38,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: ['#travel', '#nature', '#food', '#art', '#fitness']
              .map(
                (tag) => GestureDetector(
                  onTap: () => onTap(tag),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  _HighlightedText
// ─────────────────────────────────────────────────────────────
class _HighlightedText extends StatelessWidget {
  final String text;
  final String highlight;
  final TextStyle style;
  final TextStyle highlightStyle;

  const _HighlightedText({
    required this.text,
    required this.highlight,
    required this.style,
    required this.highlightStyle,
  });

  @override
  Widget build(BuildContext context) {
    if (highlight.isEmpty) return Text(text, style: style);
    final lower = text.toLowerCase();
    final idx = lower.indexOf(highlight.toLowerCase());
    if (idx == -1) return Text(text, style: style);
    return RichText(
      text: TextSpan(children: [
        if (idx > 0) TextSpan(text: text.substring(0, idx), style: style),
        TextSpan(
          text: text.substring(idx, idx + highlight.length),
          style: highlightStyle,
        ),
        if (idx + highlight.length < text.length)
          TextSpan(text: text.substring(idx + highlight.length), style: style),
      ]),
    );
  }
}
