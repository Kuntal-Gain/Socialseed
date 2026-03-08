import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socialseed/features/auth_module/ui/provider/creds_provider.dart';
import 'package:socialseed/features/friends_module/data/friend_usecases.dart';

import '../../../../core/network/locator.dart';
import '../../../auth_module/model/user_model.dart';
import '../../model/request_model.dart';

final suggestedUsersProvider =
    AutoDisposeAsyncNotifierProvider<SuggestedUsersNotifier, List<User>>(
  SuggestedUsersNotifier.new,
);

class SuggestedUsersNotifier extends AutoDisposeAsyncNotifier<List<User>> {
  @override
  Future<List<User>> build() async {
    final usecase = getIt<FriendUsecases>();
    return usecase.getSuggestions();
  }
}

final friendsProvider =
    AutoDisposeAsyncNotifierProvider<FriendsNotifier, List<User>>(
  FriendsNotifier.new,
);

class FriendsNotifier extends AutoDisposeAsyncNotifier<List<User>> {
  @override
  Future<List<User>> build() async {
    final usecase = getIt<FriendUsecases>();
    return usecase.getFriends();
  }
}

class FriendRequestsNotifier
    extends AutoDisposeAsyncNotifier<RequestListModel> {
  final _usecase = getIt<FriendUsecases>();
  StreamSubscription<RequestListModel>? _sub;

  @override
  Future<RequestListModel> build() async {
    // Start with loading
    state = const AsyncValue.loading();

    _sub = _usecase.getRequests().listen(
      (data) {
        state = AsyncValue.data(data);
      },
      onError: (e, st) {
        state = AsyncValue.error(e, st);
      },
    );

    ref.onDispose(() {
      _sub?.cancel();
    });

    // Initial empty value until first stream event
    return const RequestListModel(requests: [], count: 0);
  }

  /// 🔥 ACTIONS

  Future<void> send(RequestModel request, String toUid) async {
    await _usecase.sendRequest(request, toUid);
  }

  Future<void> accept(String reciverUid) async {
    await _usecase.acceptReq(reciverUid: reciverUid);
  }

  Future<void> reject(String reciverUid) async {
    await _usecase.rejectOrCancelReq(reciverUid: reciverUid);
  }

  Future<void> cancel(String reciverUid) async {
    await _usecase.rejectOrCancelReq(reciverUid: reciverUid);
  }
}

final friendRequestsProvider =
    AutoDisposeAsyncNotifierProvider<FriendRequestsNotifier, RequestListModel>(
  FriendRequestsNotifier.new,
);

final hasISentRequestToProvider =
    FutureProvider.family<bool, String>((ref, otherUid) async {
  final usecase = getIt<FriendUsecases>();

  final result = await usecase.isSentRequest(receiverUid: otherUid);

  return result;
});
