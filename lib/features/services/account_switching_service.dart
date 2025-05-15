import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:socialseed/app/cubits/credential/credential_cubit.dart';
import 'package:socialseed/features/services/models/account.dart';

class AccountSwitchingService {
  static const _boxName = 'storedAccounts';

  Future<void> addAccount(StoredAccount account) async {
    final box = await Hive.openBox(_boxName);

    // If the account already exists, don't add it again
    if (!box.containsKey(account.email)) {
      await box.put(account.email, account.toJson());
      debugPrint('Account added: ${account.email}');
    } else {
      // Optional: log or debug if you wanna track duplicates
      debugPrint('Account with email ${account.email} already exists.');
    }
  }

  Future<void> removeAccount(String email) async {
    final box = await Hive.openBox(_boxName);
    await box.delete(email);
  }

  Future<List<StoredAccount>> getAllAccounts() async {
    final box = await Hive.openBox(_boxName);
    debugPrint('Account box keys: ${box.keys}');
    return box.values
        .map((json) => StoredAccount.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  void switchAccount(
          BuildContext context, String email, String password) async =>
      BlocProvider.of<CredentialCubit>(context).signInUser(
        email: email,
        password: password,
        ctx: context,
      );
}
