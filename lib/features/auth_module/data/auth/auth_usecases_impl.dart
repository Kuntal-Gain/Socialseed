import 'package:firebase_auth/firebase_auth.dart';
import 'package:socialseed/features/auth_module/data/auth/auth_usecase.dart';

class AuthUsecasesImpl implements AuthUsecases {
  final _auth = FirebaseAuth.instance;

  @override
  Future<void> signup(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Future<bool> isUserLoggedIn() async => _auth.currentUser != null;

  @override
  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      print('[FIREBASE] ${e.code}');

      if (e.code == 'invalid-credential') {
        print('Invalid Credentials , Try Again');
      }

      throw e; // 👈 THIS LINE IS THE FIX
    } catch (e) {
      print(e);
      rethrow; // 👈 ALSO IMPORTANT
    }
  }

  @override
  Future<void> logout() async => await _auth.signOut();

  @override
  Future<String?> getCurrentUid() async => _auth.currentUser?.uid;
}
