import 'package:socialseed/domain/entities/chat_entity.dart';
import 'package:socialseed/domain/repos/firebase_repository.dart';

class CreateMessageWithId {
  final FirebaseRepository repository;

  CreateMessageWithId({required this.repository});

  Future<void> call(ChatEntity chat) async {
    return repository.createMessageWithId(chat);
  }
}
