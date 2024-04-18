import 'package:socialseed/domain/entities/comment_entity.dart';
import 'package:socialseed/domain/repos/firebase_repository.dart';

class UpdateCommentUsecase {
  final FirebaseRepository repository;

  UpdateCommentUsecase({required this.repository});

  Future<void> call(CommentEntity comment) {
    return repository.updateComment(comment);
  }
}
