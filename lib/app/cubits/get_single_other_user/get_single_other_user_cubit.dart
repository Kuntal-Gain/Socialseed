import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../../domain/entities/user_entity.dart';
import '../../../domain/usecases/user/get_single_other_user_usecase.dart';

part 'get_single_other_user_state.dart';

class GetSingleOtherUserCubit extends Cubit<GetSingleOtherUserState> {
  final GetSingleOtherUserUseCase getSingleOtherUserUseCase;
  StreamSubscription? _subscription;
  String? _currentUid;

  GetSingleOtherUserCubit({required this.getSingleOtherUserUseCase})
      : super(GetSingleOtherUserInitial());

  Future<void> getSingleOtherUser({required String otherUid}) async {
    // Prevent duplicate calls for same user
    if (_currentUid == otherUid && state is GetSingleOtherUserLoaded) {
      return;
    }

    emit(GetSingleOtherUserLoading());
    try {
      await _subscription?.cancel();
      _currentUid = otherUid;

      final streamResponse = getSingleOtherUserUseCase.call(otherUid);
      _subscription = streamResponse
          .distinct() // Only emit if data changed
          .listen(
        (users) {
          if (users.isNotEmpty && _currentUid == otherUid) {
            if (kDebugMode) {
              print('Emitting state for uid: $otherUid');
            } // Debug log
            emit(GetSingleOtherUserLoaded(otherUser: users.first));
          }
        },
        onError: (error) {
          if (kDebugMode) {
            print('Error in stream: $error');
          } // Debug log
          emit(GetSingleOtherUserFailure());
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Exception: $e');
      } // Debug log
      emit(GetSingleOtherUserFailure());
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    _currentUid = null;
    return super.close();
  }
}
