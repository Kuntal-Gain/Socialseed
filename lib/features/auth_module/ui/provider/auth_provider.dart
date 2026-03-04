import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socialseed/core/network/locator.dart';
import 'package:socialseed/features/auth_module/data/auth/auth_usecase.dart';
import 'package:socialseed/features/auth_module/data/auth/auth_usecases_impl.dart';

class AuthFormState {
  final String email;
  final String password;
  final bool passwordVisible;

  AuthFormState({
    this.email = '',
    this.password = '',
    this.passwordVisible = false,
  });

  AuthFormState copyWith({
    String? email,
    String? password,
    bool? passwordVisible,
  }) {
    return AuthFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      passwordVisible: passwordVisible ?? this.passwordVisible,
    );
  }
}

class AuthFormNotifier extends AsyncNotifier<AuthFormState> {
  @override
  Future<AuthFormState> build() async => AuthFormState();

  bool isLoading = false;

  void setEmail(String value) {
    final current = state.asData?.value ?? AuthFormState();
    state = AsyncData(current.copyWith(email: value));
  }

  void setPassword(String value) {
    final current = state.asData?.value ?? AuthFormState();
    state = AsyncData(current.copyWith(password: value));
  }

  void togglePasswordVisibility() {
    final current = state.asData?.value ?? AuthFormState();
    state = AsyncData(
      current.copyWith(passwordVisible: !current.passwordVisible),
    );
  }

  Future<bool> login(AuthFormState form) async {
    if (form.email.isEmpty || form.password.isEmpty) {
      print("Please fill all fields");
      return false;
    }

    isLoading = true;
    final auth = getIt<AuthUsecases>();

    try {
      await auth.login(form.email, form.password);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> signup(AuthFormState form) async {
    if (form.email.isEmpty || form.password.isEmpty) {
      print("Please fill all fields");
      return false;
    }

    isLoading = true;
    final auth = getIt<AuthUsecases>();

    try {
      await auth.signup(form.email, form.password);
      isLoading = false;
      return true;
    } catch (e) {
      print(e.toString());
      isLoading = false;
      return false;
    }
  }

  Future<void> logout() async {
    final auth = getIt<AuthUsecases>();
    await auth.logout();
  }

  Future<bool> getAuthState() async {
    final auth = getIt<AuthUsecases>();
    return await auth.isUserLoggedIn();
  }

  Future<String?> getCurrentUid() async {
    final auth = getIt<AuthUsecases>();
    return await auth.getCurrentUid();
  }
}

final authFormProvider = AsyncNotifierProvider<AuthFormNotifier, AuthFormState>(
  AuthFormNotifier.new,
);

final getCurrentUserProvider = FutureProvider<String?>((ref) async {
  final auth = getIt<AuthUsecases>();
  return await auth.getCurrentUid();
});

final getAuthStateProvider = FutureProvider<bool>((ref) async {
  final auth = getIt<AuthUsecases>();
  return await auth.isUserLoggedIn();
});
