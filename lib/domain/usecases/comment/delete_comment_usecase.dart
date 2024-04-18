import 'package:socialseed/domain/entities/comment_entity.dart';
import 'package:socialseed/domain/repos/firebase_repository.dart';

class DeleteCommentUsecase {
  final FirebaseRepository repository;

  DeleteCommentUsecase({required this.repository});

  Future<void> call(CommentEntity comment) {
    return repository.deleteComment(comment);
  }
}
