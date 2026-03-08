import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socialseed/core/network/locator.dart';
import 'package:socialseed/features/auth_module/data/cred/creds_usecase.dart';
import 'package:socialseed/features/auth_module/model/user_model.dart';

class CredsNotifier extends AutoDisposeAsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    // Load current user on init
    try {
      final usecase = getIt<CredsUseCase>();
      final currentUser = await usecase.getCurrentUser();
      return currentUser; // can be null if not logged in
    } catch (e) {
      throw Exception('Failed to fetch current user: $e');
    }
  }

  Future<void> createUser(User user) {
    try {
      final usecase = getIt<CredsUseCase>();

      print("user created");
      return usecase.createUser(user);
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  Future<void> updateUser(User user) {
    try {
      final usecase = getIt<CredsUseCase>();

      print("user updated");
      return usecase.updateProfile(user);
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  /// Toggle the online status of the current user
  Future<void> toggleOnline(bool isOnline) async {
    final user = state.value;
    if (user == null) return; // No user logged in

    try {
      final usecase = getIt<CredsUseCase>();
      await usecase.toggleOnlineStatus(user.uid!);

      // Update local state
    } catch (e) {
      rethrow;
    }
  }
}

// Provider
final credsProvider = AutoDisposeAsyncNotifierProvider<CredsNotifier, User?>(
  CredsNotifier.new,
);

final currentUserProvider = Provider.autoDispose<User?>(
  (ref) => ref.watch(credsProvider).valueOrNull,
);

class UserByIdFamilyNotifier extends FamilyAsyncNotifier<User?, String> {
  @override
  Future<User?> build(String uid) async {
    try {
      final usecase = getIt<CredsUseCase>();
      final user = await usecase.getUser(uid);
      return user;
    } catch (e) {
      throw Exception('Failed to fetch user $uid: $e');
    }
  }

  /// Optional: manually refresh this user
  Future<void> refreshUser(String uid) async {
    state = const AsyncValue.loading();
    try {
      final usecase = getIt<CredsUseCase>();
      final user = await usecase.getUser(uid);

      print(user?.toJson());

      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final userByIdProvider =
    AsyncNotifierProviderFamily<UserByIdFamilyNotifier, User?, String>(
  UserByIdFamilyNotifier.new,
);
