part of 'auth_cubit.dart';

abstract class AuthState extends Equatable {
  const AuthState();
}

class AuthInitial extends AuthState {
  @override
  List<Object> get props => [];
}

class Authenticated extends AuthState {
  final String uid;

  const Authenticated({required this.uid});

  @override
  List<Object> get props => [uid];
}

class NotAuthenticated extends AuthState {
  const NotAuthenticated();

  @override
  List<Object> get props => [];
}

class NoInternet extends AuthState {
  const NoInternet();

  @override
  List<Object> get props => [];
}
