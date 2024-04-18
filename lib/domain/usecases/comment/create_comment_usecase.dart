import 'package:socialseed/domain/entities/comment_entity.dart';
import 'package:socialseed/domain/repos/firebase_repository.dart';

class CreateCommentUsecase {
  final FirebaseRepository repository;

  CreateCommentUsecase({required this.repository});

  Future<void> call(CommentEntity comment) {
    return repository.createComment(comment);
  }
}
