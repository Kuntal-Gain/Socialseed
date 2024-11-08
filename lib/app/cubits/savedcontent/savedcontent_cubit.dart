import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:socialseed/domain/entities/post_entity.dart';
import 'package:socialseed/domain/usecases/user/fetch_saved_content_usecase.dart';
import 'package:socialseed/domain/usecases/user/get_current_uid_usecase.dart';
import 'package:socialseed/domain/usecases/user/save_post_usecase.dart';

part 'savedcontent_state.dart';

class SavedcontentCubit extends Cubit<SavedcontentState> {
  SavedcontentCubit({
    required this.savePostUsecase,
    required this.fetchSavedContentUsecase,
    required this.getCurrentUidUsecase,
  }) : super(SavedcontentInitial());

  final SavePostUsecase savePostUsecase;
  final FetchSavedContentUsecase fetchSavedContentUsecase;
  final GetCurrentUidUsecase getCurrentUidUsecase;

  // Save a post
  Future<void> savePost(PostEntity post) async {
    final uid = await getCurrentUidUsecase.call();

    try {
      emit(SavedcontentLoading()); // Emit loading state
      await savePostUsecase.call(post); // Call the use case to save the post

      fetchPosts(uid: uid);
    } catch (e) {
      emit(
          SavedcontentFailure(message: 'Failed to save post: ${e.toString()}'));
    }
  }

  Future<void> fetchPosts({required String uid}) async {
    try {
      emit(SavedcontentLoading()); // Emit loading state

      // Fetch the saved posts as a stream and listen to updates
      fetchSavedContentUsecase.call(uid).listen(
        (savedPosts) {
          emit(SavedcontentLoaded(
              savedPosts: savedPosts)); // Emit loaded state with posts
        },
        onError: (_) {
          emit(const SavedcontentFailure(
              message: 'Failed to fetch saved posts'));
        },
      );
    } catch (e) {
      emit(const SavedcontentFailure(message: 'Failed to fetch saved posts'));
    }
  }
}
