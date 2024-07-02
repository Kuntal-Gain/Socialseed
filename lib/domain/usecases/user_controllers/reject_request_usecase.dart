import 'package:socialseed/domain/entities/user_entity.dart';
import 'package:socialseed/domain/repos/firebase_repository.dart';

class RejectRequestUsecase {
  final FirebaseRepository repository;

  RejectRequestUsecase({required this.repository});

  Future<void> call(UserEntity user) async {
    return repository.rejectRequest(user);
  }
}
