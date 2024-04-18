import 'package:flutter/material.dart';
import 'package:socialseed/domain/entities/user_entity.dart';
import 'package:socialseed/domain/repos/firebase_repository.dart';

class SignUpUsecase {
  final FirebaseRepository repository;

  SignUpUsecase({required this.repository});

  Future<void> call(UserEntity user, BuildContext ctx) {
    return repository.signUpUser(user, ctx);
  }
}
