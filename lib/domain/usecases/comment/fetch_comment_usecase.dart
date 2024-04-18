import 'package:socialseed/domain/entities/comment_entity.dart';
import 'package:socialseed/domain/repos/firebase_repository.dart';

class FetchCommentUsecase {
  final FirebaseRepository repository;

  FetchCommentUsecase({required this.repository});

  Stream<List<CommentEntity>> call(String postId) {
    return repository.fetchComments(postId);
  }
}
