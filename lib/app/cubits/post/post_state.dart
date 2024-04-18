part of 'post_cubit.dart';

sealed class PostState extends Equatable {
  const PostState();
}

final class PostInitial extends PostState {
  @override
  List<Object> get props => [];
}

final class PostLoading extends PostState {
  @override
  List<Object> get props => [];
}

final class PostLoaded extends PostState {
  final List<PostEntity> posts;

  const PostLoaded({required this.posts});

  @override
  List<Object> get props => [posts];
}

final class PostFailure extends PostState {
  @override
  List<Object> get props => [];
}
