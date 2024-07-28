import 'package:socialseed/domain/repos/firebase_repository.dart';

class IsMessageIdExistsUsecase {
  final FirebaseRepository repository;

  IsMessageIdExistsUsecase({required this.repository});

  Future<bool> call(String messageId) async {
    return repository.isMessageIdExists(messageId);
  }
}
