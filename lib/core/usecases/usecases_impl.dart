import 'package:socialseed/core/network/locator.dart';
import 'package:socialseed/features/auth_module/data/auth/auth_usecase.dart';

Future<String> getCurrentUid() async {
  final auth = getIt<AuthUsecases>();
  final uid = await auth.getCurrentUid();
  if (uid == null || uid.isEmpty) {
    throw Exception('No user logged in');
  }
  return uid;
}
