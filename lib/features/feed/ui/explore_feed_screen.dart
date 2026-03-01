import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socialseed/core/services/route_generator.dart';
import 'package:socialseed/core/utils/helpers/app_loader.dart';
import 'package:socialseed/core/utils/helpers/failure_widget.dart';
import 'package:socialseed/features/post/model/post_model.dart';
import 'package:socialseed/features/post/ui/provider/post_provider.dart';

import 'widget/search_widget.dart';

// Mock models - replace with your actual models
class ExplorePost {
  final String id;
  final String imageUrl;
  final String creatorName;
  final String creatorAvatar;
  final int likes;
  final int comments;
  final bool isVideo;

  ExplorePost({
    required this.id,
    required this.imageUrl,
    required this.creatorName,
    required this.creatorAvatar,
    required this.likes,
    required this.comments,
    this.isVideo = false,
  });
}

class ExploreFeedScreen extends ConsumerStatefulWidget {
  const ExploreFeedScreen({super.key});

  @override
  ConsumerState<ExploreFeedScreen> createState() => _ExploreFeedScreenState();
}

class _ExploreFeedScreenState extends ConsumerState<ExploreFeedScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Mock data - replace with your actual provider
  final List<ExplorePost> _explorePosts = [
    ExplorePost(
      id: '1',
      imageUrl:
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
      creatorName: 'Sarah Johnson',
      creatorAvatar:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
      likes: 1234,
      comments: 56,
    ),
    ExplorePost(
      id: '2',
      imageUrl:
          'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=400',
      creatorName: 'Michael Chen',
      creatorAvatar:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
      likes: 3421,
      comments: 123,
      isVideo: true,
    ),
    ExplorePost(
      id: '3',
      imageUrl:
          'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=400',
      creatorName: 'Emily Davis',
      creatorAvatar:
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150',
      likes: 892,
      comments: 34,
    ),
    ExplorePost(
      id: '4',
      imageUrl:
          'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=400',
      creatorName: 'Alex Martinez',
      creatorAvatar:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
      likes: 5621,
      comments: 234,
    ),
    ExplorePost(
      id: '5',
      imageUrl:
          'https://images.unsplash.com/photo-1426604966848-d7adac402bff?w=400',
      creatorName: 'Jessica Taylor',
      creatorAvatar:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      likes: 2145,
      comments: 89,
      isVideo: true,
    ),
    ExplorePost(
      id: '6',
      imageUrl:
          'https://images.unsplash.com/photo-1472214103451-9374bd1c798e?w=400',
      creatorName: 'David Kim',
      creatorAvatar:
          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150',
      likes: 4532,
      comments: 167,
    ),
    ExplorePost(
      id: '7',
      imageUrl:
          'https://images.unsplash.com/photo-1511884642898-4c92249e20b6?w=400',
      creatorName: 'Rachel Moore',
      creatorAvatar:
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150',
      likes: 1876,
      comments: 72,
    ),
    ExplorePost(
      id: '8',
      imageUrl:
          'https://images.unsplash.com/photo-1475924156734-496f6cac6ec1?w=400',
      creatorName: 'Chris Park',
      creatorAvatar:
          'https://images.unsplash.com/photo-1519345182560-3f2917c472ef?w=150',
      likes: 3298,
      comments: 145,
      isVideo: true,
    ),
    ExplorePost(
      id: '9',
      imageUrl:
          'https://images.unsplash.com/photo-1483728642387-6c3bdd6c93e5?w=400',
      creatorName: 'Lisa Anderson',
      creatorAvatar:
          'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=150',
      likes: 987,
      comments: 45,
    ),
    ExplorePost(
      id: '10',
      imageUrl:
          'https://images.unsplash.com/photo-1501594907352-04cda38ebc29?w=400',
      creatorName: 'Tom Wilson',
      creatorAvatar:
          'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=150',
      likes: 6754,
      comments: 289,
    ),
    ExplorePost(
      id: '11',
      imageUrl:
          'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?w=400',
      creatorName: 'Nina Patel',
      creatorAvatar:
          'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=150',
      likes: 2341,
      comments: 98,
    ),
    ExplorePost(
      id: '12',
      imageUrl:
          'https://images.unsplash.com/photo-1518895949257-7621c3c786d7?w=400',
      creatorName: 'Jake Smith',
      creatorAvatar:
          'https://images.unsplash.com/photo-1463453091185-61582044d556?w=150',
      likes: 1598,
      comments: 67,
      isVideo: true,
    ),
  ];

  final List<String> _categories = [
    'All',
    'Travel',
    'Food',
    'Fashion',
    'Nature',
    'Art',
    'Fitness',
    'Technology',
  ];

  int _selectedCategoryIndex = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openPostDetail(PostModel post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPostDetailSheet(post),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(feedProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            // Padding(
            //   padding: const EdgeInsets.all(16),
            //   child: Container(
            //     decoration: BoxDecoration(
            //       color: Colors.grey.shade100,
            //       borderRadius: BorderRadius.circular(12),
            //     ),
            //     child: TextField(
            //       controller: _searchController,
            //       decoration: InputDecoration(
            //         hintText: 'Search',
            //         hintStyle: TextStyle(
            //           color: Colors.grey.shade500,
            //           fontSize: 15,
            //         ),
            //         prefixIcon: Icon(
            //           Icons.search,
            //           color: Colors.grey.shade600,
            //         ),
            //         border: InputBorder.none,
            //         contentPadding: const EdgeInsets.symmetric(
            //           horizontal: 16,
            //           vertical: 14,
            //         ),
            //       ),
            //       style: const TextStyle(fontSize: 15),
            //     ),
            //   ),
            // ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: const ExploreSearchBar(),
            ),

            // Categories
            // SizedBox(
            //   height: 44,
            //   child: ListView.builder(
            //     scrollDirection: Axis.horizontal,
            //     padding: const EdgeInsets.symmetric(horizontal: 16),
            //     itemCount: _categories.length,
            //     itemBuilder: (context, index) {
            //       final isSelected = _selectedCategoryIndex == index;
            //       return GestureDetector(
            //         onTap: () {
            //           setState(() {
            //             _selectedCategoryIndex = index;
            //           });
            //         },
            //         child: Container(
            //           margin: const EdgeInsets.only(right: 8),
            //           padding: const EdgeInsets.symmetric(
            //             horizontal: 20,
            //             vertical: 10,
            //           ),
            //           decoration: BoxDecoration(
            //             color: isSelected
            //                 ? const Color(0xffFF3131)
            //                 : Colors.grey.shade100,
            //             borderRadius: BorderRadius.circular(20),
            //           ),
            //           child: Center(
            //             child: Text(
            //               _categories[index],
            //               style: TextStyle(
            //                 color: isSelected ? Colors.white : Colors.black87,
            //                 fontSize: 14,
            //                 fontWeight:
            //                     isSelected ? FontWeight.w600 : FontWeight.w500,
            //               ),
            //             ),
            //           ),
            //         ),
            //       );
            //     },
            //   ),
            // ),

            const SizedBox(height: 16),

            // Grid of Posts
            state.when(
                loading: () => AppLoader().stateLoader(),
                error: (e, s) => errorWidget(e, s),
                data: (data) {
                  final posts = [
                    ...data.where((e) => e.type != PostType.text),
                    ...data.where((e) => e.type != PostType.text),
                    ...data.where((e) => e.type != PostType.text)
                  ];

                  return Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1,
                      ),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        return _buildGridItem(post);
                      },
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem(PostModel post) {
    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, RouteGenerator.kPostView, arguments: {
        'post': post,
      }),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              post.assets?.first ?? "",
              fit: BoxFit.cover,
            ),
          ),

          // Video Indicator
          if (post.type == PostType.video)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),

          // Hover Overlay with Stats
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.pushNamed(
                    context, RouteGenerator.kPostView,
                    arguments: {
                      'post': post,
                    }),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Stats at bottom
          Positioned(
            bottom: 6,
            right: 6,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 12,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        _formatNumber(post.likes?.length ?? 0),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostDetailSheet(PostModel post) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: NetworkImage(post.creator!.avatarUrl!),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        post.creator?.name ?? "",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              // Image
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AspectRatio(
                        aspectRatio: 1,
                        child: Image.network(
                          post.assets?.first ?? "",
                          fit: BoxFit.cover,
                        ),
                      ),

                      // Action Buttons
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.favorite_border),
                                  onPressed: () {},
                                  iconSize: 28,
                                ),
                                Text(
                                  _formatNumber(post.likes?.length ?? 0),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.chat_bubble_outline),
                                  onPressed: () {},
                                  iconSize: 28,
                                ),
                                Text(
                                  _formatNumber(post.comments?.length ?? 0),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.send_outlined),
                              onPressed: () {},
                              iconSize: 28,
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.bookmark_border),
                              onPressed: () {},
                              iconSize: 28,
                            ),
                          ],
                        ),
                      ),

                      // Caption
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              height: 1.4,
                            ),
                            children: [
                              TextSpan(
                                text: post.creator?.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const TextSpan(
                                text:
                                    ' Amazing view from my recent trip! Can\'t wait to go back here again. 🌅',
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // View Comments
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'View all ${post.comments} comments',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Time
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          '2 hours ago',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Comment Input
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Text(
                            'Add a comment...',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(
                          Icons.favorite,
                          color: Color(0xffFF3131),
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
