part of 'get_single_user_cubit.dart';

abstract class GetSingleUserState extends Equatable {
  const GetSingleUserState();
}

class GetSingleUsersInitial extends GetSingleUserState {
  @override
  List<Object> get props => [];
}

class GetSingleUsersLoading extends GetSingleUserState {
  @override
  List<Object> get props => [];
}

class GetSingleUsersLoaded extends GetSingleUserState {
  final UserEntity user;

  const GetSingleUsersLoaded({required this.user});

  @override
  List<Object> get props => [user];
}

class GetSingleUsersFailure extends GetSingleUserState {
  final String msg;

  const GetSingleUsersFailure({required this.msg});

  @override
  List<Object> get props => [msg];
}
