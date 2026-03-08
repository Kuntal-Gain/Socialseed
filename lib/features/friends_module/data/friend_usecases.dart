import 'package:socialseed/features/auth_module/model/user_model.dart';
import 'package:socialseed/features/friends_module/model/request_model.dart';

abstract class FriendUsecases {
  Future<List<User>> getSuggestions();
  Stream<RequestListModel> getRequests();
  Future<List<User>> getFriends();
  Future<void> sendRequest(RequestModel request, String toUid);
  Future<void> acceptReq({required String reciverUid});
  Future<void> rejectOrCancelReq({required String reciverUid});
  Future<bool> isSentRequest({required String receiverUid});
}
