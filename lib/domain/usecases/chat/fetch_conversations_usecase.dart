import 'package:socialseed/domain/entities/chat_entity.dart';
import 'package:socialseed/domain/repos/firebase_repository.dart';

class FetchConversationUsecase {
  final FirebaseRepository repository;

  FetchConversationUsecase({required this.repository});

  Stream<List<ChatEntity>> call() {
    return repository.fetchConversations();
  }
}
