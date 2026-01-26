abstract class AuthUsecases {
  Future<void> signup(String email, String password);
  Future<void> login(String email, String password);
  Future<void> logout();
  Future<String?> getCurrentUid();
  Future<bool> isUserLoggedIn();
}
