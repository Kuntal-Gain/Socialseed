import 'package:socialseed/domain/entities/message_entity.dart';
import 'package:socialseed/domain/repos/firebase_repository.dart';

class FetchMessageUsecase {
  final FirebaseRepository repository;

  FetchMessageUsecase({required this.repository});

  Stream<List<MessageEntity>> call(String messageId) {
    return repository.fetchMessages(messageId);
  }
}
