import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:socialseed/domain/entities/user_entity.dart';
import 'package:socialseed/domain/usecases/user/get_user_usecase.dart';
import 'package:socialseed/domain/usecases/user/update_user_usecase.dart';
import 'package:socialseed/domain/usecases/user_controllers/accept_request_usecase.dart';
import 'package:socialseed/domain/usecases/user_controllers/follow_user_usecase.dart';
import 'package:socialseed/domain/usecases/user_controllers/reject_request_usecase.dart';
import 'package:socialseed/domain/usecases/user_controllers/send_request_usecase.dart';
import 'package:socialseed/domain/usecases/user_controllers/unfollow_user_usecase.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final UpdateUserUsecase updateUserUseCase;
  final GetUserUsecase getUsersUseCase;
  final FollowUserUsecase followUserUsecase;
  final UnFollowUserUsecase unFollowUserUsecase;
  final SendRequestUsecase sendRequestUsecase;
  final AcceptRequestUsecase acceptRequestUsecase;
  final RejectRequestUsecase rejectRequestUsecase;
  UserCubit({
    required this.updateUserUseCase,
    required this.getUsersUseCase,
    required this.acceptRequestUsecase,
    required this.followUserUsecase,
    required this.sendRequestUsecase,
    required this.unFollowUserUsecase,
    required this.rejectRequestUsecase,
  }) : super(UserInitial());

  Future<void> getUsers({required UserEntity user}) async {
    emit(UserLoading());
    try {
      final streamResponse = getUsersUseCase.call(user);
      streamResponse.listen((users) {
        emit(UserLoaded(users: users));
      });
    } on SocketException catch (_) {
      emit(UserFailure());
    } catch (_) {
      emit(UserFailure());
    }
  }

  Future<void> updateUser({required UserEntity user}) async {
    try {
      await updateUserUseCase.call(user);
    } on SocketException catch (_) {
      emit(UserFailure());
    } catch (_) {
      emit(UserFailure());
    }
  }

  Future<void> followUser({required UserEntity user}) async {
    try {
      await followUserUsecase.call(user);
    } on SocketException catch (_) {
      emit(UserFailure());
    } catch (_) {
      emit(UserFailure());
    }
  }

  Future<void> unFollowUser({required UserEntity user}) async {
    try {
      await unFollowUserUsecase.call(user);
    } on SocketException catch (_) {
      emit(UserFailure());
    } catch (_) {
      emit(UserFailure());
    }
  }

  Future<void> sendRequest({required UserEntity user}) async {
    try {
      await sendRequestUsecase.call(user);
    } on SocketException catch (_) {
      emit(UserFailure());
    } catch (_) {
      emit(UserFailure());
    }
  }

  Future<void> acceptRequest({required UserEntity user}) async {
    try {
      await acceptRequestUsecase.call(user);
    } on SocketException catch (_) {
      emit(UserFailure());
    } catch (_) {
      emit(UserFailure());
    }
  }

  Future<void> rejectRequest({required UserEntity user}) async {
    try {
      await rejectRequestUsecase.call(user);
    } on SocketException catch (_) {
      emit(UserFailure());
    } catch (_) {
      emit(UserFailure());
    }
  }
}
