import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:socialseed/domain/usecases/comment/create_comment_usecase.dart';
import 'package:socialseed/domain/usecases/comment/delete_comment_usecase.dart';
import 'package:socialseed/domain/usecases/comment/fetch_comment_usecase.dart';
import 'package:socialseed/domain/usecases/comment/like_comment_usecase.dart';
import 'package:socialseed/domain/usecases/comment/update_comment_usecase.dart';

import '../../../../domain/entities/comment_entity.dart';

part 'comment_state.dart';

class CommentCubit extends Cubit<CommentState> {
  final CreateCommentUsecase createCommentUsecase;
  final DeleteCommentUsecase deleteCommentUseCase;
  final LikeCommentUsecase likeCommentUseCase;
  final FetchCommentUsecase fetchCommentsUseCase;
  final UpdateCommentUsecase updateCommentUseCase;
  CommentCubit(
      {required this.updateCommentUseCase,
      required this.fetchCommentsUseCase,
      required this.likeCommentUseCase,
      required this.deleteCommentUseCase,
      required this.createCommentUsecase})
      : super(CommentInitial());

  Future<void> getComments({required String postId}) async {
    emit(CommentLoading());
    try {
      final streamResponse = fetchCommentsUseCase.call(postId);
      streamResponse.listen((comments) {
        emit(CommentLoaded(comments: comments));
      });
    } on SocketException catch (_) {
      emit(CommentFailure());
    } catch (_) {
      emit(CommentFailure());
    }
  }

  Future<void> likeComment({required CommentEntity comment}) async {
    try {
      await likeCommentUseCase.call(comment);
    } on SocketException catch (_) {
      emit(CommentFailure());
    } catch (_) {
      emit(CommentFailure());
    }
  }

  Future<void> deleteComment({required CommentEntity comment}) async {
    try {
      await deleteCommentUseCase.call(comment);
    } on SocketException catch (_) {
      emit(CommentFailure());
    } catch (_) {
      emit(CommentFailure());
    }
  }

  Future<void> createComment({required CommentEntity comment}) async {
    try {
      await createCommentUsecase.call(comment);
    } on SocketException catch (_) {
      emit(CommentFailure());
    } catch (_) {
      emit(CommentFailure());
    }
  }

  Future<void> updateComment({required CommentEntity comment}) async {
    try {
      await updateCommentUseCase.call(comment);
    } on SocketException catch (_) {
      emit(CommentFailure());
    } catch (_) {
      emit(CommentFailure());
    }
  }
}
