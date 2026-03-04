// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'dart:async';

// // Mock models - replace with your actual models
// class StoryItem {
//   final String id;
//   final String imageUrl;
//   final String? videoUrl;
//   final DateTime timestamp;
//   final Duration duration;

//   StoryItem({
//     required this.id,
//     required this.imageUrl,
//     this.videoUrl,
//     required this.timestamp,
//     this.duration = const Duration(seconds: 5),
//   });
// }

// class StoryViewer {
//   final String uid;
//   final String name;
//   final String avatarUrl;
//   final DateTime viewedAt;

//   StoryViewer({
//     required this.uid,
//     required this.name,
//     required this.avatarUrl,
//     required this.viewedAt,
//   });
// }

// class StoryUser {
//   final String uid;
//   final String name;
//   final String avatarUrl;
//   final List<StoryItem> stories;

//   StoryUser({
//     required this.uid,
//     required this.name,
//     required this.avatarUrl,
//     required this.stories,
//   });
// }

// class StoryViewScreen extends ConsumerStatefulWidget {
//   final StoryUser user;
//   final int initialStoryIndex;

//   const StoryViewScreen({
//     super.key,
//     required this.user,
//     this.initialStoryIndex = 0,
//   });

//   @override
//   ConsumerState<StoryViewScreen> createState() => _StoryViewScreenState();
// }

// class _StoryViewScreenState extends ConsumerState<StoryViewScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _progressController;
//   late int _currentStoryIndex;
//   bool _isPaused = false;
//   bool _showViewers = false;

//   // Mock viewers data - replace with your actual provider
//   final List<StoryViewer> _viewers = [
//     StoryViewer(
//       uid: 'user1',
//       name: 'Sarah Johnson',
//       avatarUrl:
//           'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
//       viewedAt: DateTime.now().subtract(const Duration(minutes: 5)),
//     ),
//     StoryViewer(
//       uid: 'user2',
//       name: 'Michael Chen',
//       avatarUrl:
//           'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
//       viewedAt: DateTime.now().subtract(const Duration(minutes: 12)),
//     ),
//     StoryViewer(
//       uid: 'user3',
//       name: 'Emily Davis',
//       avatarUrl:
//           'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150',
//       viewedAt: DateTime.now().subtract(const Duration(hours: 1)),
//     ),
//     StoryViewer(
//       uid: 'user4',
//       name: 'Alex Martinez',
//       avatarUrl:
//           'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
//       viewedAt: DateTime.now().subtract(const Duration(hours: 2)),
//     ),
//     StoryViewer(
//       uid: 'user5',
//       name: 'Jessica Taylor',
//       avatarUrl:
//           'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
//       viewedAt: DateTime.now().subtract(const Duration(hours: 3)),
//     ),
//     StoryViewer(
//       uid: 'user6',
//       name: 'David Kim',
//       avatarUrl:
//           'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150',
//       viewedAt: DateTime.now().subtract(const Duration(hours: 5)),
//     ),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _currentStoryIndex = widget.initialStoryIndex;
//     _progressController = AnimationController(
//       vsync: this,
//       duration: widget.user.stories[_currentStoryIndex].duration,
//     );

//     _progressController.addStatusListener((status) {
//       if (status == AnimationStatus.completed) {
//         _nextStory();
//       }
//     });

//     _startStory();
//   }

//   @override
//   void dispose() {
//     _progressController.dispose();
//     super.dispose();
//   }

//   void _startStory() {
//     _progressController.forward();
//   }

//   void _pauseStory() {
//     setState(() {
//       _isPaused = true;
//     });
//     _progressController.stop();
//   }

//   void _resumeStory() {
//     setState(() {
//       _isPaused = false;
//     });
//     _progressController.forward();
//   }

//   void _nextStory() {
//     if (_currentStoryIndex < widget.user.stories.length - 1) {
//       setState(() {
//         _currentStoryIndex++;
//         _progressController.reset();
//         _progressController.duration =
//             widget.user.stories[_currentStoryIndex].duration;
//       });
//       _startStory();
//     } else {
//       Navigator.pop(context);
//     }
//   }

//   void _previousStory() {
//     if (_currentStoryIndex > 0) {
//       setState(() {
//         _currentStoryIndex--;
//         _progressController.reset();
//         _progressController.duration =
//             widget.user.stories[_currentStoryIndex].duration;
//       });
//       _startStory();
//     }
//   }

//   void _toggleViewers() {
//     if (_showViewers) {
//       setState(() {
//         _showViewers = false;
//       });
//       _resumeStory();
//     } else {
//       _pauseStory();
//       setState(() {
//         _showViewers = true;
//       });
//     }
//   }

//   String _getTimeAgo(DateTime dateTime) {
//     final difference = DateTime.now().difference(dateTime);
//     if (difference.inDays > 0) {
//       return '${difference.inDays}d ago';
//     } else if (difference.inHours > 0) {
//       return '${difference.inHours}h ago';
//     } else if (difference.inMinutes > 0) {
//       return '${difference.inMinutes}m ago';
//     } else {
//       return 'Just now';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final currentStory = widget.user.stories[_currentStoryIndex];

//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: GestureDetector(
//         onTapDown: (details) {
//           final screenWidth = MediaQuery.of(context).size.width;
//           final dx = details.globalPosition.dx;

//           if (dx < screenWidth / 3) {
//             _previousStory();
//           } else if (dx > 2 * screenWidth / 3) {
//             _nextStory();
//           }
//         },
//         onLongPressStart: (_) => _pauseStory(),
//         onLongPressEnd: (_) => _resumeStory(),
//         child: Stack(
//           children: [
//             // Story Image
//             Positioned.fill(
//               child: Image.network(
//                 currentStory.imageUrl,
//                 fit: BoxFit.contain,
//               ),
//             ),

//             // Gradient Overlays
//             Positioned(
//               top: 0,
//               left: 0,
//               right: 0,
//               child: Container(
//                 height: 200,
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     colors: [
//                       Colors.black.withOpacity(0.6),
//                       Colors.transparent,
//                     ],
//                   ),
//                 ),
//               ),
//             ),

//             // Top Section
//             SafeArea(
//               child: Column(
//                 children: [
//                   // Progress Bars
//                   Padding(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 8,
//                       vertical: 8,
//                     ),
//                     child: Row(
//                       children: List.generate(
//                         widget.user.stories.length,
//                         (index) => Expanded(
//                           child: Container(
//                             margin: const EdgeInsets.symmetric(horizontal: 2),
//                             height: 3,
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(0.3),
//                               borderRadius: BorderRadius.circular(2),
//                             ),
//                             child: AnimatedBuilder(
//                               animation: _progressController,
//                               builder: (context, child) {
//                                 double progress;
//                                 if (index < _currentStoryIndex) {
//                                   progress = 1.0;
//                                 } else if (index == _currentStoryIndex) {
//                                   progress = _progressController.value;
//                                 } else {
//                                   progress = 0.0;
//                                 }

//                                 return FractionallySizedBox(
//                                   alignment: Alignment.centerLeft,
//                                   widthFactor: progress,
//                                   child: Container(
//                                     decoration: BoxDecoration(
//                                       color: Colors.white,
//                                       borderRadius: BorderRadius.circular(2),
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),

//                   // User Info Header
//                   Padding(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 8,
//                     ),
//                     child: Row(
//                       children: [
//                         // Avatar
//                         Container(
//                           padding: const EdgeInsets.all(2),
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             border: Border.all(
//                               color: const Color(0xffFF3131),
//                               width: 2,
//                             ),
//                           ),
//                           child: CircleAvatar(
//                             radius: 18,
//                             backgroundColor: Colors.grey.shade800,
//                             backgroundImage:
//                                 NetworkImage(widget.user.avatarUrl),
//                           ),
//                         ),
//                         const SizedBox(width: 10),

//                         // Name and Time
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 widget.user.name,
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 15,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                               Text(
//                                 _getTimeAgo(currentStory.timestamp),
//                                 style: TextStyle(
//                                   color: Colors.white.withOpacity(0.7),
//                                   fontSize: 12,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),

//                         // Pause/Play Icon
//                         if (_isPaused)
//                           Container(
//                             padding: const EdgeInsets.all(8),
//                             decoration: BoxDecoration(
//                               color: Colors.black.withOpacity(0.3),
//                               shape: BoxShape.circle,
//                             ),
//                             child: const Icon(
//                               Icons.play_arrow,
//                               color: Colors.white,
//                               size: 20,
//                             ),
//                           ),

//                         const SizedBox(width: 8),

//                         // More Options
//                         IconButton(
//                           icon: const Icon(
//                             Icons.more_vert,
//                             color: Colors.white,
//                             size: 24,
//                           ),
//                           onPressed: () {
//                             // Show options
//                           },
//                         ),

//                         // Close Button
//                         IconButton(
//                           icon: const Icon(
//                             Icons.close,
//                             color: Colors.white,
//                             size: 24,
//                           ),
//                           onPressed: () => Navigator.pop(context),
//                         ),
//                       ],
//                     ),
//                   ),

//                   const Spacer(),

//                   // Bottom Actions
//                   Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Row(
//                       children: [
//                         // Reply Input
//                         Expanded(
//                           child: GestureDetector(
//                             onTap: () {
//                               _pauseStory();
//                               _showReplyBottomSheet();
//                             },
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 16,
//                                 vertical: 12,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: Colors.black.withOpacity(0.4),
//                                 borderRadius: BorderRadius.circular(24),
//                                 border: Border.all(
//                                   color: Colors.white.withOpacity(0.3),
//                                   width: 1,
//                                 ),
//                               ),
//                               child: Row(
//                                 children: [
//                                   Icon(
//                                     Icons.chat_bubble_outline,
//                                     color: Colors.white.withOpacity(0.8),
//                                     size: 20,
//                                   ),
//                                   const SizedBox(width: 12),
//                                   Text(
//                                     'Send message...',
//                                     style: TextStyle(
//                                       color: Colors.white.withOpacity(0.7),
//                                       fontSize: 14,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 12),

//                         // Like Button
//                         Container(
//                           padding: const EdgeInsets.all(12),
//                           decoration: BoxDecoration(
//                             color: Colors.black.withOpacity(0.4),
//                             shape: BoxShape.circle,
//                             border: Border.all(
//                               color: Colors.white.withOpacity(0.3),
//                               width: 1,
//                             ),
//                           ),
//                           child: const Icon(
//                             Icons.favorite_border,
//                             color: Colors.white,
//                             size: 22,
//                           ),
//                         ),

//                         const SizedBox(width: 12),

//                         // Share Button
//                         Container(
//                           padding: const EdgeInsets.all(12),
//                           decoration: BoxDecoration(
//                             color: Colors.black.withOpacity(0.4),
//                             shape: BoxShape.circle,
//                             border: Border.all(
//                               color: Colors.white.withOpacity(0.3),
//                               width: 1,
//                             ),
//                           ),
//                           child: const Icon(
//                             Icons.send_outlined,
//                             color: Colors.white,
//                             size: 22,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   // Viewers Button (Unique Feature)
//                   GestureDetector(
//                     onTap: _toggleViewers,
//                     child: Container(
//                       margin: const EdgeInsets.only(bottom: 16),
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 20,
//                         vertical: 12,
//                       ),
//                       decoration: BoxDecoration(
//                         color: const Color(0xffFF3131),
//                         borderRadius: BorderRadius.circular(24),
//                         boxShadow: [
//                           BoxShadow(
//                             color: const Color(0xffFF3131).withOpacity(0.3),
//                             blurRadius: 12,
//                             offset: const Offset(0, 4),
//                           ),
//                         ],
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           const Icon(
//                             Icons.visibility_outlined,
//                             color: Colors.white,
//                             size: 18,
//                           ),
//                           const SizedBox(width: 8),
//                           Text(
//                             '${_viewers.length} Views',
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 14,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                           const SizedBox(width: 4),
//                           Icon(
//                             _showViewers
//                                 ? Icons.keyboard_arrow_down
//                                 : Icons.keyboard_arrow_up,
//                             color: Colors.white,
//                             size: 18,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Viewers Panel (Unique Design)
//             if (_showViewers)
//               Positioned(
//                 left: 0,
//                 right: 0,
//                 bottom: 0,
//                 child: GestureDetector(
//                   onTap: () {}, // Prevent tap from closing
//                   child: Container(
//                     constraints: BoxConstraints(
//                       maxHeight: MediaQuery.of(context).size.height * 0.6,
//                     ),
//                     decoration: const BoxDecoration(
//                       color: Color(0xffF1F4F8),
//                       borderRadius: BorderRadius.vertical(
//                         top: Radius.circular(24),
//                       ),
//                     ),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         // Handle
//                         Container(
//                           margin: const EdgeInsets.only(top: 12, bottom: 8),
//                           width: 40,
//                           height: 4,
//                           decoration: BoxDecoration(
//                             color: const Color(0xffc2c2c2),
//                             borderRadius: BorderRadius.circular(2),
//                           ),
//                         ),

//                         // Header
//                         Padding(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 20,
//                             vertical: 16,
//                           ),
//                           child: Row(
//                             children: [
//                               const Icon(
//                                 Icons.visibility,
//                                 color: Color(0xffFF3131),
//                                 size: 24,
//                               ),
//                               const SizedBox(width: 12),
//                               Text(
//                                 'Viewed by ${_viewers.length}',
//                                 style: const TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.w600,
//                                   color: Colors.black,
//                                 ),
//                               ),
//                               const Spacer(),
//                               IconButton(
//                                 icon: const Icon(
//                                   Icons.close,
//                                   color: Colors.black87,
//                                 ),
//                                 onPressed: _toggleViewers,
//                               ),
//                             ],
//                           ),
//                         ),

//                         const Divider(height: 1),

//                         // Viewers List
//                         Flexible(
//                           child: ListView.builder(
//                             shrinkWrap: true,
//                             padding: const EdgeInsets.symmetric(vertical: 8),
//                             itemCount: _viewers.length,
//                             itemBuilder: (context, index) {
//                               final viewer = _viewers[index];
//                               return _buildViewerItem(viewer, index);
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildViewerItem(StoryViewer viewer, int index) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: [
//           // Rank Badge (Unique Feature)
//           Container(
//             width: 32,
//             height: 32,
//             decoration: BoxDecoration(
//               color: index < 3
//                   ? const Color(0xffFF3131).withOpacity(0.1)
//                   : const Color(0xffF1F4F8),
//               shape: BoxShape.circle,
//             ),
//             child: Center(
//               child: Text(
//                 '${index + 1}',
//                 style: TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w700,
//                   color: index < 3
//                       ? const Color(0xffFF3131)
//                       : const Color(0xff677681),
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),

//           // Avatar
//           CircleAvatar(
//             radius: 22,
//             backgroundColor: const Color(0xffF1F4F8),
//             backgroundImage: NetworkImage(viewer.avatarUrl),
//           ),
//           const SizedBox(width: 12),

//           // Name and Time
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   viewer.name,
//                   style: const TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.black,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   _getTimeAgo(viewer.viewedAt),
//                   style: const TextStyle(
//                     fontSize: 12,
//                     color: Color(0xff677681),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // View Profile Button
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             decoration: BoxDecoration(
//               color: const Color(0xffFF3131).withOpacity(0.1),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: const Text(
//               'View',
//               style: TextStyle(
//                 fontSize: 13,
//                 fontWeight: FontWeight.w600,
//                 color: Color(0xffFF3131),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showReplyBottomSheet() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Padding(
//         padding: EdgeInsets.only(
//           bottom: MediaQuery.of(context).viewInsets.bottom,
//         ),
//         child: Container(
//           padding: const EdgeInsets.all(20),
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 width: 40,
//                 height: 4,
//                 decoration: BoxDecoration(
//                   color: const Color(0xffc2c2c2),
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               TextField(
//                 autofocus: true,
//                 decoration: InputDecoration(
//                   hintText: 'Send a message...',
//                   hintStyle: const TextStyle(color: Color(0xff677681)),
//                   filled: true,
//                   fillColor: const Color(0xffF1F4F8),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide.none,
//                   ),
//                   suffixIcon: IconButton(
//                     icon: const Icon(
//                       Icons.send,
//                       color: Color(0xffFF3131),
//                     ),
//                     onPressed: () {
//                       Navigator.pop(context);
//                       _resumeStory();
//                     },
//                   ),
//                 ),
//                 maxLines: 3,
//                 minLines: 1,
//               ),
//             ],
//           ),
//         ),
//       ),
//     ).then((_) => _resumeStory());
//   }
// }

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:socialseed/core/utils/helpers/app_loader.dart';
import 'package:socialseed/core/utils/helpers/failure_widget.dart';
import 'package:socialseed/features/auth_module/model/user_model.dart';
import 'package:socialseed/features/auth_module/ui/provider/creds_provider.dart';
import 'package:socialseed/features/story/model/story_model.dart';

class StoryViewer {
  final String uid;
  final String name;
  final String avatarUrl;
  final DateTime viewedAt;

  StoryViewer({
    required this.uid,
    required this.name,
    required this.avatarUrl,
    required this.viewedAt,
  });
}

class StoryViewScreen extends ConsumerStatefulWidget {
  final StoryModel story;
  final int initialAssetIndex;

  const StoryViewScreen({
    super.key,
    required this.story,
    this.initialAssetIndex = 0,
  });

  @override
  ConsumerState<StoryViewScreen> createState() => _StoryViewScreenState();
}

class _StoryViewScreenState extends ConsumerState<StoryViewScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late int _currentAssetIndex;
  bool _isPaused = false;
  bool _showViewers = false;

  List<StoryAsset> get _assets => widget.story.assets ?? [];
  StoryAsset get _currentAsset => _assets[_currentAssetIndex];

  Duration _durationForAsset(StoryAsset asset) {
    return asset.type == StoryAssetType.video
        ? const Duration(seconds: 15)
        : const Duration(seconds: 5);
  }

  // Mock viewers — replace with actual Firestore fetch using story.viewers (List<String> of UIDs)
  final List<StoryViewer> _viewers = [
    StoryViewer(
      uid: 'user1',
      name: 'Sarah Johnson',
      avatarUrl:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
      viewedAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    StoryViewer(
      uid: 'user2',
      name: 'Michael Chen',
      avatarUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
      viewedAt: DateTime.now().subtract(const Duration(minutes: 12)),
    ),
    StoryViewer(
      uid: 'user3',
      name: 'Emily Davis',
      avatarUrl:
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150',
      viewedAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentAssetIndex = widget.initialAssetIndex.clamp(0, _assets.length - 1);
    _progressController = AnimationController(
      vsync: this,
      duration: _durationForAsset(_currentAsset),
    );
    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) _nextAsset();
    });
    _startStory();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  void _startStory() => _progressController.forward();

  void _pauseStory() {
    setState(() => _isPaused = true);
    _progressController.stop();
  }

  void _resumeStory() {
    setState(() => _isPaused = false);
    _progressController.forward();
  }

  void _nextAsset() {
    if (_currentAssetIndex < _assets.length - 1) {
      setState(() {
        _currentAssetIndex++;
        _progressController.reset();
        _progressController.duration = _durationForAsset(_currentAsset);
      });
      _startStory();
    } else {
      Navigator.pop(context);
    }
  }

  void _previousAsset() {
    if (_currentAssetIndex > 0) {
      setState(() {
        _currentAssetIndex--;
        _progressController.reset();
        _progressController.duration = _durationForAsset(_currentAsset);
      });
      _startStory();
    }
  }

  void _toggleViewers() {
    if (_showViewers) {
      setState(() => _showViewers = false);
      _resumeStory();
    } else {
      _pauseStory();
      setState(() => _showViewers = true);
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  String _timestampTimeAgo(Timestamp? ts) {
    if (ts == null) return '';
    return _getTimeAgo(ts.toDate());
  }

  Color _parseHexColor(String hex) {
    try {
      final buffer = StringBuffer();
      if (hex.length == 7) buffer.write('ff');
      buffer.write(hex.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_assets.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child:
              Text('No story content', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    final userAsync =
        ref.watch(userByIdProvider(widget.story.creatorUid ?? ""));

    return Scaffold(
      backgroundColor: Colors.black,
      body: userAsync.when(
          loading: () => AppLoader().stateLoader(),
          error: (e, s) => errorWidget(e, s),
          data: (user) {
            return GestureDetector(
              onTapDown: (details) {
                final screenWidth = MediaQuery.of(context).size.width;
                final dx = details.globalPosition.dx;
                if (dx < screenWidth / 3) {
                  _previousAsset();
                } else if (dx > 2 * screenWidth / 3) {
                  _nextAsset();
                }
              },
              onLongPressStart: (_) => _pauseStory(),
              onLongPressEnd: (_) => _resumeStory(),
              child: Stack(
                children: [
                  // ── Story Content ──────────────────────────────────────────────
                  Positioned.fill(child: _buildAssetContent(_currentAsset)),

                  // ── Top Gradient ───────────────────────────────────────────────
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── Top Section ────────────────────────────────────────────────
                  SafeArea(
                    child: Column(
                      children: [
                        // Progress Bars
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                          child: Row(
                            children: List.generate(
                              _assets.length,
                              (index) => Expanded(
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 2),
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: AnimatedBuilder(
                                    animation: _progressController,
                                    builder: (context, _) {
                                      double progress;
                                      if (index < _currentAssetIndex) {
                                        progress = 1.0;
                                      } else if (index == _currentAssetIndex) {
                                        progress = _progressController.value;
                                      } else {
                                        progress = 0.0;
                                      }
                                      return FractionallySizedBox(
                                        alignment: Alignment.centerLeft,
                                        widthFactor: progress,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(2),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // User Info Header — uses creatorUid for display
                        // Replace CircleAvatar backgroundImage with your user provider
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xffFF3131),
                                    width: 2,
                                  ),
                                ),
                                // TODO: replace with avatar fetched via widget.story.creatorUid
                                child: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Colors.grey.shade800,
                                  backgroundImage: user?.avatar != null
                                      ? NetworkImage('${user?.avatar}')
                                      : null,
                                  child: user?.avatar != null
                                      ? null
                                      : Text(
                                          user?.fullName
                                                  ?.substring(0, 1)
                                                  .toUpperCase() ??
                                              '?',
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // TODO: replace with display name fetched via creatorUid
                                    Text(
                                      user?.fullName ?? 'Unknown',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      _timestampTimeAgo(widget.story.createdAt),
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (_isPaused)
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.3),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.play_arrow,
                                      color: Colors.white, size: 20),
                                ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.more_vert,
                                    color: Colors.white, size: 24),
                                onPressed: () {},
                              ),
                              IconButton(
                                icon: const Icon(Icons.close,
                                    color: Colors.white, size: 24),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        ),

                        // Caption overlay (for image/video assets)
                        if (_currentAsset.caption.isNotEmpty &&
                            _currentAsset.type != StoryAssetType.text)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _currentAsset.caption,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 14),
                                ),
                              ),
                            ),
                          ),

                        const Spacer(),

                        // Bottom Actions
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    _pauseStory();
                                    _showReplyBottomSheet();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.chat_bubble_outline,
                                            color:
                                                Colors.white.withOpacity(0.8),
                                            size: 20),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Send message...',
                                          style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.7),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              _iconButton(Icons.favorite_border),
                              const SizedBox(width: 12),
                              _iconButton(Icons.send_outlined),
                            ],
                          ),
                        ),

                        // Viewers Button
                        GestureDetector(
                          onTap: _toggleViewers,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xffFF3131),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xffFF3131).withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.visibility_outlined,
                                    color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  '${widget.story.viewers?.length ?? 0} Views',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  _showViewers
                                      ? Icons.keyboard_arrow_down
                                      : Icons.keyboard_arrow_up,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Viewers Panel ──────────────────────────────────────────────
                  if (_showViewers)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.6,
                          ),
                          decoration: const BoxDecoration(
                            color: Color(0xffF1F4F8),
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(24)),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                margin:
                                    const EdgeInsets.only(top: 12, bottom: 8),
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: const Color(0xffc2c2c2),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 16),
                                child: Row(
                                  children: [
                                    const Icon(Icons.visibility,
                                        color: Color(0xffFF3131), size: 24),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Viewed by ${widget.story.viewers?.length ?? 0}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      icon: const Icon(Icons.close,
                                          color: Colors.black87),
                                      onPressed: _toggleViewers,
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(height: 1),
                              Flexible(
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    itemCount:
                                        widget.story.viewers?.length ?? 0,
                                    itemBuilder: (context, index) {
                                      final userId =
                                          widget.story.viewers?[index];

                                      final _userAsync = ref.watch(
                                          userByIdProvider(userId ?? ""));

                                      final user = _userAsync.maybeWhen(
                                        data: (user) => user,
                                        orElse: () => null,
                                      );

                                      return _buildViewerItem(user, index);
                                    }),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
    );
  }

  Widget _buildAssetContent(StoryAsset asset) {
    switch (asset.type) {
      case StoryAssetType.image:
        return asset.url != null
            ? CachedNetworkImage(
                imageUrl: asset.url!,
                fit: BoxFit.contain,
                errorWidget: (context, error, stackTrace) =>
                    _colorBackground(asset.bg),
              )
            : _colorBackground(asset.bg);

      case StoryAssetType.video:
        // TODO: replace with video_player widget using asset.url
        return Stack(
          fit: StackFit.expand,
          children: [
            _colorBackground(asset.bg),
            const Center(
              child:
                  Icon(Icons.play_circle_fill, color: Colors.white70, size: 72),
            ),
          ],
        );

      case StoryAssetType.text:
        return Container(
          color: _parseHexColor(asset.bg),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            asset.caption,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
    }
  }

  Widget _colorBackground(String hex) => Container(color: _parseHexColor(hex));

  Widget _iconButton(IconData icon) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      );

  Widget _buildViewerItem(User? user, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: index < 3
                  ? const Color(0xffFF3131).withOpacity(0.1)
                  : const Color(0xffF1F4F8),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: index < 3
                      ? const Color(0xffFF3131)
                      : const Color(0xff677681),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xffF1F4F8),
            backgroundImage: NetworkImage(user?.avatar ?? ""),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.fullName ?? "Unknown User",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                // TODO: ** implement later **
                // const SizedBox(height: 2),
                // Text(
                //   _getTimeAgo(viewer.viewedAt),
                //   style:
                //       const TextStyle(fontSize: 12, color: Color(0xff677681)),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showReplyBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xffc2c2c2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Send a message...',
                  hintStyle: const TextStyle(color: Color(0xff677681)),
                  filled: true,
                  fillColor: const Color(0xffF1F4F8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send, color: Color(0xffFF3131)),
                    onPressed: () {
                      Navigator.pop(context);
                      _resumeStory();
                    },
                  ),
                ),
                maxLines: 3,
                minLines: 1,
              ),
            ],
          ),
        ),
      ),
    ).then((_) => _resumeStory());
  }
}
