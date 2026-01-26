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

  /// Refresh the current user from Firestore manually
  Future<void> refreshUser() async {
    state = const AsyncValue.loading();
    try {
      final usecase = getIt<CredsUseCase>();
      final currentUser = await usecase.getCurrentUser();
      state = AsyncValue.data(currentUser);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Toggle the online status of the current user
  Future<void> toggleOnline(bool isOnline) async {
    final user = state.value;
    if (user == null) return; // No user logged in

    state = const AsyncValue.loading();
    try {
      final usecase = getIt<CredsUseCase>();
      await usecase.toggleOnlineStatus(user.uid!);

      // Update local state
      final updatedUser = user.copyWith(isOnline: isOnline);
      state = AsyncValue.data(updatedUser);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// Provider
final credsProvider = AutoDisposeAsyncNotifierProvider<CredsNotifier, User?>(
  CredsNotifier.new,
);
