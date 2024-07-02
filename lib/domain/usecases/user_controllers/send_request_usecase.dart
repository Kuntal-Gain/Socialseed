import 'package:socialseed/domain/entities/user_entity.dart';
import 'package:socialseed/domain/repos/firebase_repository.dart';

class SendRequestUsecase {
  final FirebaseRepository repository;

  SendRequestUsecase({required this.repository});

  Future<void> call(UserEntity user) async {
    return repository.sendRequest(user);
  }
}
