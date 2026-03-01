import 'package:get_it/get_it.dart';
import 'package:socialseed/features/auth_module/data/auth/auth_usecase.dart';
import 'package:socialseed/features/auth_module/data/auth/auth_usecases_impl.dart';
import 'package:socialseed/features/auth_module/data/cred/creds_usecase.dart';
import 'package:socialseed/features/auth_module/data/cred/creds_usecases_impl.dart';
import 'package:socialseed/features/friends_module/data/friend_usecase_impl.dart';
import 'package:socialseed/features/friends_module/data/friend_usecases.dart';
import 'package:socialseed/features/post/data/post_usecase.dart';
import 'package:socialseed/features/post/data/post_usecase_impl.dart';
import 'package:socialseed/features/story/data/story_usecase.dart';
import 'package:socialseed/features/story/data/story_usecase_impl.dart';

final getIt = GetIt.instance;

void init() {
  getIt.registerLazySingleton<AuthUsecases>(() => AuthUsecasesImpl());
  getIt.registerLazySingleton<CredsUseCase>(() => CredsUseCasesImpl());
  getIt.registerLazySingleton<PostUsecase>(() => PostUsecaseImpl());
  getIt.registerLazySingleton<FriendUsecases>(() => FriendUsecaseImpl());
  getIt.registerLazySingleton<StoryUsecase>(() => StoryUsecaseImpl());
}
