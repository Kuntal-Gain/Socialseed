import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:socialseed/domain/usecases/user/get_current_uid_usecase.dart';
import 'package:socialseed/domain/usecases/creds/is_signin_usecase.dart';
import 'package:socialseed/domain/usecases/creds/sign_out_usecase.dart';
import 'package:socialseed/domain/usecases/user/update_user_status_usecase.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SignOutUsecase signOutUsecase;
  final GetCurrentUidUsecase getCurrentUidUsecase;
  final IsSignInUsecase isSignInUsecase;

  final UpdateUserStatusUsecase updateUserStatusUsecase;

  AuthCubit({
    required this.signOutUsecase,
    required this.getCurrentUidUsecase,
    required this.isSignInUsecase,
    required this.updateUserStatusUsecase,
  }) : super(AuthInitial());

  Future<void> appStarted(BuildContext context) async {
    try {
      bool isSignIn = await isSignInUsecase.call();

      if (isSignIn == true) {
        final uid = await getCurrentUidUsecase.call();
        emit(Authenticated(uid: uid));
      } else {
        emit(const NotAuthenticated());
      }
    } catch (_) {
      emit(const NotAuthenticated());
    }
  }

  Future<void> loggedIn() async {
    try {
      final uid = await getCurrentUidUsecase.call();
      emit(Authenticated(uid: uid));
    } catch (_) {
      emit(const NotAuthenticated());
    }
  }

  Future<void> logout() async {
    try {
      await signOutUsecase.call();
      emit(const NotAuthenticated());
    } catch (_) {
      emit(const NotAuthenticated());
    }
  }
}
