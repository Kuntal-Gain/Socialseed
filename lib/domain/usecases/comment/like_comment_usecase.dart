import 'package:socialseed/domain/entities/comment_entity.dart';
import 'package:socialseed/domain/repos/firebase_repository.dart';

class LikeCommentUsecase {
  final FirebaseRepository repository;

  LikeCommentUsecase({required this.repository});

  Future<void> call(CommentEntity comment) {
    return repository.likeComment(comment);
  }
}
