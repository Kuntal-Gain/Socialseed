part of 'story_cubit.dart';

abstract class StoryState extends Equatable {
  const StoryState();

  @override
  List<Object> get props => [];
}

// Initial state when no action has been taken
class StoryInitial extends StoryState {}

// State when stories have been successfully loaded
class StoryLoaded extends StoryState {
  final List<StoryEntity> stories;

  const StoryLoaded(this.stories);

  @override
  List<Object> get props => [stories];
}

// State when a story has been viewed by the user
class StoryViewed extends StoryState {
  final String storyId;

  const StoryViewed(this.storyId);

  @override
  List<Object> get props => [storyId];
}

// State when a story has not been viewed by the user
class StoryNotViewed extends StoryState {
  final String storyId;

  const StoryNotViewed(this.storyId);

  @override
  List<Object> get props => [storyId];
}

class StoryFailure extends StoryState {
  final String error;

  const StoryFailure(this.error);

  @override
  List<Object> get props => [error];
}
