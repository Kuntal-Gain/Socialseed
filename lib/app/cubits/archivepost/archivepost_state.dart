part of 'archivepost_cubit.dart';

abstract class ArchivepostState extends Equatable {
  const ArchivepostState();
}

class ArchivepostInitial extends ArchivepostState {
  @override
  List<Object> get props => [];
}

class ArchivepostLoading extends ArchivepostState {
  @override
  List<Object> get props => [];
}

class ArchivepostLoaded extends ArchivepostState {
  final List<PostEntity> archivePosts;

  const ArchivepostLoaded({required this.archivePosts});

  @override
  List<Object> get props => [archivePosts];
}

class ArchivepostFailure extends ArchivepostState {
  final String error;

  const ArchivepostFailure({required this.error});

  @override
  List<Object> get props => [error];
}
