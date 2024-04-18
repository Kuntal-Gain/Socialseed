import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:socialseed/domain/entities/user_entity.dart';
import 'package:socialseed/domain/usecases/user/get_single_user_usecase.dart';

part 'get_single_user_state.dart';

class GetSingleUserCubit extends Cubit<GetSingleUserState> {
  final GetSingleUserUsecase singleUserUsecase;
  GetSingleUserCubit({required this.singleUserUsecase})
      : super(GetSingleUsersInitial());

  Future<void> getSingleUsers({required String uid}) async {
    emit(GetSingleUsersLoading());
    try {
      final streamResponse = singleUserUsecase.call(uid);

      // Listen to the stream response
      streamResponse.listen((users) {
        // Check if users list is not empty
        if (users.isNotEmpty) {
          emit(GetSingleUsersLoaded(user: users.first));
        } else {
          // If users list is empty, emit failure state
          emit(const GetSingleUsersFailure(msg: 'empty users set'));
        }
      }, onError: (error) {
        // Handle stream errors, emit failure state
        emit(GetSingleUsersFailure(msg: error.toString()));
      });
    } on SocketException catch (_) {
      // Handle socket exceptions, emit failure state
      emit(const GetSingleUsersFailure(msg: 'Internet Error 404'));
    } catch (_) {
      // Handle other exceptions, emit failure state
      emit(const GetSingleUsersFailure(msg: 'something went error'));
    }
  }
}
