import 'package:socialseed/domain/entities/user_entity.dart';
import 'package:socialseed/domain/repos/firebase_repository.dart';

class AcceptRequestUsecase {
  final FirebaseRepository repository;

  AcceptRequestUsecase({required this.repository});

  Future<void> call(UserEntity user) async {
    return repository.acceptRequest(user);
  }
}
