import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:socialseed/domain/entities/post_entity.dart';
import 'package:socialseed/domain/usecases/post/fetch_single_post_usecase.dart';
import 'package:socialseed/domain/usecases/post/like_post_usecase.dart';

part 'get_single_post_state.dart';

class GetSinglePostCubit extends Cubit<GetSinglePostState> {
  final FetchSinglePostUsecase fetchSinglePostUsecase;
  final LikePostUsecase likePostUsecase;

  GetSinglePostCubit(
      {required this.fetchSinglePostUsecase, required this.likePostUsecase})
      : super(GetSinglePostInitial());

  Future<void> getSinglePost({required String postId}) async {
    emit(GetSinglePostLoading());

    try {
      final streamResponse = fetchSinglePostUsecase.call(postId);

      streamResponse.listen((posts) {
        emit(GetSinglePostLoaded(post: posts.first));
      });
    } on SocketException catch (_) {
      emit(const GetSinglePostFailure(
          message: 'No Internet , Please Check your Intenet'));
    } catch (_) {
      emit(const GetSinglePostFailure(message: 'Something Went Wrong'));
    }
  }

  Future<void> likePost({required PostEntity post}) async {
    try {
      await likePostUsecase.call(post);
    } on SocketException catch (_) {
      emit(const GetSinglePostFailure(message: 'Network Error'));
    } catch (_) {
      emit(const GetSinglePostFailure(message: 'Something Went Wrong'));
    }
  }
}
