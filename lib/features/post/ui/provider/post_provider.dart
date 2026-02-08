import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socialseed/core/network/locator.dart';
import 'package:socialseed/core/provider/user_provider.dart';
import 'package:socialseed/features/post/data/post_usecase.dart';

import 'package:socialseed/features/post/model/post_model.dart';

class FeedState {
  final List<PostModel> posts;
  final bool isLoading;
  final bool hasMore;
  final String? error;

  const FeedState({
    this.posts = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.error,
  });

  FeedState copyWith({
    List<PostModel>? posts,
    bool? isLoading,
    bool? hasMore,
    String? error,
  }) {
    return FeedState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error,
    );
  }
}

/// [FEED]
class FeedNotifier extends AutoDisposeAsyncNotifier<List<PostModel>> {
  final _usecase = getIt<PostUsecase>();
  DocumentSnapshot? _lastDoc;
  bool _hasMore = true;

  @override
  Future<List<PostModel>> build() async {
    return fetchPosts();
  }

  Future<List<PostModel>> fetchPosts({int limit = 10}) async {
    state = const AsyncValue.loading();
    try {
      final posts = await _usecase.getAllPosts(limit: limit, lastDoc: _lastDoc);

      if (posts.isNotEmpty) {
        // Update _lastDoc for pagination
        _lastDoc = null; // ideally you store last doc snapshot for next page
      } else {
        _hasMore = false;
      }

      state = AsyncValue.data(posts);
      return posts;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> loadMore({int limit = 10}) async {
    if (!_hasMore) return;
    try {
      final posts = await _usecase.getAllPosts(limit: limit, lastDoc: _lastDoc);

      if (posts.isEmpty) {
        _hasMore = false;
      } else {
        _lastDoc = null; // store last doc for next page
      }

      state = AsyncValue.data([...state.value ?? [], ...posts]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createPost(PostModel post) async {
    try {
      await _usecase.createPost(post);
      // refresh feed
      await fetchPosts();
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }
}

// Provider
final feedProvider =
    AutoDisposeAsyncNotifierProvider<FeedNotifier, List<PostModel>>(
  FeedNotifier.new,
);

/// [USER] post
class UserPostsNotifier extends AutoDisposeAsyncNotifier<List<PostModel>> {
  final _usecase = getIt<PostUsecase>();

  @override
  Future<List<PostModel>> build() async {
    state = const AsyncValue.loading();

    try {
      // Read current UID from another provider
      final uid = await ref.read(getCurrentUidProvider);

      final posts = await _usecase.getUserPosts(uid);
      state = AsyncValue.data(posts);
      return posts;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final uid = await ref.read(getCurrentUidProvider);

      final posts = await _usecase.getUserPosts(uid);
      state = AsyncValue.data(posts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// Provider
final userPostsProvider =
    AutoDisposeAsyncNotifierProvider<UserPostsNotifier, List<PostModel>>(
  UserPostsNotifier.new,
);

final userPostsCountProvider = Provider.autoDispose(
  (ref) => ref.watch(userPostsProvider).valueOrNull?.length ?? 0,
);

/// [SINGLE POST] method
class SinglePostNotifier extends AutoDisposeAsyncNotifier<PostModel> {
  final _usecase = getIt<PostUsecase>();

  @override
  Future<PostModel> build() async {
    // Read the current selected post ID
    final postId = ref.watch(selectedPostProvider);
    if (postId == null) throw Exception("No post selected");

    return fetchPost(postId);
  }

  Future<PostModel> fetchPost(String postId) async {
    state = const AsyncValue.loading();
    try {
      final post = await _usecase.getPost(postId);
      state = AsyncValue.data(post);
      return post;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> refresh() async {
    final postId = ref.watch(selectedPostProvider);
    if (postId == null) return;

    state = const AsyncValue.loading();
    try {
      final post = await _usecase.getPost(postId);
      state = AsyncValue.data(post);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// Provider
final singlePostProvider =
    AutoDisposeAsyncNotifierProvider<SinglePostNotifier, PostModel>(
  SinglePostNotifier.new,
);

final selectedPostProvider = StateProvider<String?>((ref) => null);

class PostLikeState {
  final int count;
  final bool isLikedByMe;
  final List<String> likedUids;

  PostLikeState({
    required this.count,
    required this.isLikedByMe,
    required this.likedUids,
  });

  factory PostLikeState.empty() => PostLikeState(
        count: 0,
        isLikedByMe: false,
        likedUids: [],
      );
}

class PostLikeNotifier
    extends AutoDisposeFamilyAsyncNotifier<PostLikeState, String> {
  final _usecase = getIt<PostUsecase>();
  StreamSubscription<List<String>>? _sub;

  @override
  Future<PostLikeState> build(String postId) async {
    state = const AsyncValue.loading();

    final uid = await ref.watch(getCurrentUidProvider);

    // Subscribe to the list of UIDs who liked
    _sub = _usecase.likeCountStream(postId).listen(
      (uids) {
        state = AsyncValue.data(PostLikeState(
          count: uids.length,
          isLikedByMe: uids.contains(uid),
          likedUids: uids,
        ));
      },
      onError: (e, st) {
        state = AsyncValue.error(e, st);
      },
    );

    ref.onDispose(() => _sub?.cancel());

    return PostLikeState.empty();
  }

  Future<void> toggleLike() async {
    await _usecase.toggleLikePost(arg);
  }
}

final postLikeProvider = AutoDisposeAsyncNotifierProvider.family<
    PostLikeNotifier, PostLikeState, String>(
  PostLikeNotifier.new,
);

class PostCommentsNotifier
    extends AutoDisposeFamilyAsyncNotifier<List<Comment>, String> {
  final _usecase = getIt<PostUsecase>();
  StreamSubscription<List<Comment>>? _sub;

  @override
  Future<List<Comment>> build(String postId) async {
    // Start with loading
    state = const AsyncValue.loading();

    _sub = _usecase.getComments(postId).listen(
      (comments) {
        state = AsyncValue.data(comments);
      },
      onError: (e, st) {
        state = AsyncValue.error(e, st);
      },
    );

    ref.onDispose(() {
      _sub?.cancel();
    });

    // Initial empty value until first stream event
    return [];
  }

  Future<void> createComment(Comment comment) async {
    await _usecase.createComment(arg, comment);
  }

  Future<void> deleteComment(String commentId) async {
    await _usecase.deleteComment(arg, commentId);
  }

  Future<void> replyToComment(String commentId, SubComment reply) async {
    await _usecase.replyComment(arg, commentId, reply);
  }
}

final postCommentsProvider = AutoDisposeAsyncNotifierProvider.family<
    PostCommentsNotifier, List<Comment>, String>(
  PostCommentsNotifier.new,
);
