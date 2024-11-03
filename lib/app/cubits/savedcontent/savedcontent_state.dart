part of 'savedcontent_cubit.dart';

abstract class SavedcontentState extends Equatable {
  const SavedcontentState();
}

class SavedcontentInitial extends SavedcontentState {
  @override
  List<Object> get props => [];
}

class SavedcontentLoading extends SavedcontentState {
  @override
  List<Object> get props => [];
}

class SavedcontentLoaded extends SavedcontentState {
  final List<PostEntity> savedPosts;

  const SavedcontentLoaded({required this.savedPosts});

  @override
  List<Object> get props => [savedPosts];
}

class SavedcontentFailure extends SavedcontentState {
  final String message;

  const SavedcontentFailure({required this.message});

  @override
  List<Object> get props => [message];
}
