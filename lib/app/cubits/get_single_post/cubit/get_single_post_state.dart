part of 'get_single_post_cubit.dart';

sealed class GetSinglePostState extends Equatable {
  const GetSinglePostState();
}

final class GetSinglePostInitial extends GetSinglePostState {
  @override
  List<Object> get props => [];
}

final class GetSinglePostLoading extends GetSinglePostState {
  @override
  List<Object> get props => [];
}

final class GetSinglePostLoaded extends GetSinglePostState {
  final PostEntity post;

  const GetSinglePostLoaded({required this.post});

  @override
  List<Object> get props => [post];
}

final class GetSinglePostFailure extends GetSinglePostState {
  final String message;

  const GetSinglePostFailure({required this.message});

  @override
  List<Object> get props => [message];
}
