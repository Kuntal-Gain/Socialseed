import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:socialseed/domain/entities/post_entity.dart';
import 'package:socialseed/domain/usecases/post/create_post_usecase.dart';
import 'package:socialseed/domain/usecases/post/delete_post_usecase.dart';
import 'package:socialseed/domain/usecases/post/fetch_post_usecase.dart';
import 'package:socialseed/domain/usecases/post/fetch_single_post_by_uid_usecase.dart';
import 'package:socialseed/domain/usecases/post/like_post_usecase.dart';
import 'package:socialseed/domain/usecases/post/update_post_usecase.dart';

part 'post_state.dart';

class PostCubit extends Cubit<PostState> {
  final CreatePostUsecase createPostUsecase;
  final DeletePostUsecase deletePostUsecase;
  final FetchPostUsecase fetchPostUsecase;
  final LikePostUsecase likePostUsecase;
  final UpdatePostUsecase updatePostUsecase;
  final FetchPostByUid fetchPostByUid;

  PostCubit({
    required this.createPostUsecase,
    required this.deletePostUsecase,
    required this.fetchPostUsecase,
    required this.likePostUsecase,
    required this.updatePostUsecase,
    required this.fetchPostByUid,
  }) : super(PostInitial());

  Future<void> getPosts({required PostEntity post, bool delay = false}) async {
    try {
      emit(PostLoading());
      if (delay) {
        await Future.delayed(const Duration(seconds: 2));
      }
      final streamResponse = fetchPostUsecase.call(post);
      streamResponse.listen((posts) {
        if (posts.isEmpty) {
          emit(const PostLoaded(posts: []));
        } else {
          emit(PostLoaded(posts: posts));
        }
      });
    } catch (e) {
      emit(PostFailure());
    }
  }

  Future<void> getPostsBySameUid({required String uid}) async {
    emit(PostLoading());
    try {
      final streamResponse = fetchPostByUid.call(uid);
      streamResponse.listen((posts) {
        if (posts.isEmpty) {
          emit(const PostLoaded(posts: []));
        } else {
          emit(PostLoaded(posts: posts));
        }
      });
    } on SocketException catch (_) {
      emit(PostFailure());
    } catch (_) {
      emit(PostFailure());
    }
  }

  Future<void> likePost({required PostEntity post}) async {
    try {
      await likePostUsecase.call(post);
    } on SocketException catch (_) {
      emit(PostFailure());
    } catch (_) {
      emit(PostFailure());
    }
  }

  Future<void> createPost({required PostEntity post}) async {
    try {
      await createPostUsecase.call(post);
    } on SocketException catch (_) {
      emit(PostFailure());
    } catch (_) {
      emit(PostFailure());
    }
  }

  Future<void> updatePost({required PostEntity post}) async {
    try {
      await updatePostUsecase.call(post);
    } on SocketException catch (_) {
      emit(PostFailure());
    } catch (_) {
      emit(PostFailure());
    }
  }

  Future<void> deletePost({required PostEntity post}) async {
    try {
      await deletePostUsecase.call(post);
    } on SocketException catch (_) {
      emit(PostFailure());
    } catch (_) {
      emit(PostFailure());
    }
  }
}
