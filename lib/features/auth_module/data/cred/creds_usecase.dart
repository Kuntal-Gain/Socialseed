import 'package:socialseed/features/auth_module/model/user_model.dart';

abstract class CredsUseCase {
  /// [POST] Methods
  Future<void> createUser(User user);
  Future<void> updateProfile(User user);
  Future<void> deleteUser(String uid);

  /// [GET] Methods
  Future<User?> getUser(String uid);
  Future<List<User>> getAllUsers();
  Future<List<User>> searchUser(String query);
  Future<User?> getCurrentUser();

  /// [PUT] Methods
  Future<void> toggleOnlineStatus(String uid);
}
