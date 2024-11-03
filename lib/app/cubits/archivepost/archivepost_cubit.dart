import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:socialseed/domain/usecases/user/archieve_post_usecase.dart';
import 'package:socialseed/domain/usecases/user/fetch_archieved_posts.dart';
import 'package:socialseed/domain/usecases/user/get_current_uid_usecase.dart';

import '../../../domain/entities/post_entity.dart';

part 'archivepost_state.dart';

class ArchivepostCubit extends Cubit<ArchivepostState> {
  ArchivepostCubit({
    required this.getCurrentUidUsecase,
    required this.archievePostUsecase,
    required this.fetchArchievedPosts,
  }) : super(ArchivepostInitial());

  final GetCurrentUidUsecase getCurrentUidUsecase;
  final ArchievePostUsecase archievePostUsecase;
  final FetchArchievedPosts fetchArchievedPosts;

  Future<void> archivePost(PostEntity post) async {
    final uid = await getCurrentUidUsecase.call();

    try {
      emit(ArchivepostLoading());

      await archievePostUsecase.call(post);

      fetchPosts(uid: uid);
    } catch (_) {
      emit(ArchivepostFailure(error: 'Something Went Wrong'));
    }
  }

  Future<void> fetchPosts({required String uid}) async {
    try {
      emit(ArchivepostLoading());

      fetchArchievedPosts.call(uid).listen((posts) {
        emit(ArchivepostLoaded(archivePosts: posts));
      }).onError((_) {
        emit(ArchivepostFailure(error: 'Something Went Wrong'));
      });
    } catch (_) {
      emit(ArchivepostFailure(error: 'Something Went Wrong'));
    }
  }
}
