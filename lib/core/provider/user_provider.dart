import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socialseed/core/network/locator.dart';
import 'package:socialseed/features/auth_module/data/auth/auth_usecase.dart';

final getCurrentUidProvider = Provider<Future<String>>((ref) {
  final auth = getIt<AuthUsecases>();

  final uid = auth.getCurrentUid();

  return uid.then((value) {
    if (value == null || value.isEmpty) {
      return Future.error("No user logged in");
    }
    return value;
  });
});
