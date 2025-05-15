import 'package:hive/hive.dart';

part 'stored_account.g.dart';

@HiveType(typeId: 0)
class StoredAccount extends HiveObject {
  @HiveField(0)
  final String email;

  @HiveField(1)
  final String password;

  @HiveField(2)
  final String username;

  StoredAccount(
      {required this.email, required this.password, required this.username});
}
