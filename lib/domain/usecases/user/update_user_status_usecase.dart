import 'package:socialseed/domain/repos/firebase_repository.dart';

class UpdateUserStatusUsecase {
  final FirebaseRepository repository;

  UpdateUserStatusUsecase({required this.repository});

  Future<void> call(String uid, bool isOnline) {
    return repository.updateUserStatus(uid, isOnline);
  }
}
