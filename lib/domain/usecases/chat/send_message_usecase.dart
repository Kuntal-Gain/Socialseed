import 'package:socialseed/domain/repos/firebase_repository.dart';

class SendMessageUsecase {
  final FirebaseRepository repository;

  SendMessageUsecase({required this.repository});

  Future<void> call(String messageId, String message) async {
    return repository.sendMessage(messageId, message);
  }
}
