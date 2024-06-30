import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:socialseed/app/cubits/auth/auth_cubit.dart';
import 'package:socialseed/app/cubits/comment/cubit/comment_cubit.dart';
import 'package:socialseed/app/cubits/credential/credential_cubit.dart';
import 'package:socialseed/app/cubits/get_single_post/cubit/get_single_post_cubit.dart';
import 'package:socialseed/app/cubits/get_single_user/get_single_user_cubit.dart';
import 'package:socialseed/app/cubits/post/post_cubit.dart';
import 'package:socialseed/app/cubits/users/user_cubit.dart';
import 'package:socialseed/data/data_source/remote_datasource.dart';
import 'package:socialseed/data/data_source/remote_datasource_impl.dart';
import 'package:socialseed/data/repos/firebase_repository_impl.dart';
import 'package:socialseed/domain/repos/firebase_repository.dart';
import 'package:socialseed/domain/usecases/comment/create_comment_usecase.dart';
import 'package:socialseed/domain/usecases/comment/delete_comment_usecase.dart';
import 'package:socialseed/domain/usecases/comment/fetch_comment_usecase.dart';
import 'package:socialseed/domain/usecases/comment/like_comment_usecase.dart';
import 'package:socialseed/domain/usecases/comment/update_comment_usecase.dart';
import 'package:socialseed/domain/usecases/post/create_post_usecase.dart';
import 'package:socialseed/domain/usecases/post/delete_post_usecase.dart';
import 'package:socialseed/domain/usecases/post/fetch_post_usecase.dart';
import 'package:socialseed/domain/usecases/post/fetch_single_post_by_uid_usecase.dart';
import 'package:socialseed/domain/usecases/post/fetch_single_post_usecase.dart';
import 'package:socialseed/domain/usecases/post/like_post_usecase.dart';
import 'package:socialseed/domain/usecases/post/update_post_usecase.dart';

import 'package:socialseed/domain/usecases/user/create_user_usecase.dart';
import 'package:socialseed/domain/usecases/user/get_current_uid_usecase.dart';
import 'package:socialseed/domain/usecases/user/get_single_user_usecase.dart';
import 'package:socialseed/domain/usecases/user/get_user_usecase.dart';
import 'package:socialseed/domain/usecases/user/is_signin_usecase.dart';
import 'package:socialseed/domain/usecases/user/sign_in_usecase.dart';
import 'package:socialseed/domain/usecases/user/sign_out_usecase.dart';
import 'package:socialseed/domain/usecases/user/sign_up_usecase.dart';
import 'package:socialseed/domain/usecases/user/update_user_usecase.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // cubits

  sl.registerFactory(
    () => AuthCubit(
      signOutUsecase: sl.call(),
      isSignInUsecase: sl.call(),
      getCurrentUidUsecase: sl.call(),
    ),
  );

  sl.registerFactory(
    () => CredentialCubit(
      signUpUsecase: sl.call(),
      signInUsecase: sl.call(),
    ),
  );

  sl.registerFactory(
    () => UserCubit(
      updateUserUseCase: sl.call(),
      getUsersUseCase: sl.call(),
    ),
  );

  sl.registerFactory(
    () => GetSingleUserCubit(
      singleUserUsecase: sl.call(),
    ),
  );

  sl.registerFactory(
    () => PostCubit(
      createPostUsecase: sl.call(),
      deletePostUsecase: sl.call(),
      fetchPostUsecase: sl.call(),
      likePostUsecase: sl.call(),
      updatePostUsecase: sl.call(),
      fetchPostByUid: sl.call(),
    ),
  );

  sl.registerFactory(
    () => GetSinglePostCubit(
      fetchSinglePostUsecase: sl.call(),
      likePostUsecase: sl.call(),
    ),
  );

  sl.registerFactory(
    () => CommentCubit(
      updateCommentUseCase: sl.call(),
      fetchCommentsUseCase: sl.call(),
      likeCommentUseCase: sl.call(),
      deleteCommentUseCase: sl.call(),
      createCommentUsecase: sl.call(),
    ),
  );

  // usecase

  // user usecases
  sl.registerLazySingleton(() => SignOutUsecase(repository: sl.call()));
  sl.registerLazySingleton(() => IsSignInUsecase(repository: sl.call()));
  sl.registerLazySingleton(() => GetCurrentUidUsecase(repository: sl.call()));
  sl.registerLazySingleton(() => SignUpUsecase(repository: sl.call()));
  sl.registerLazySingleton(() => SignInUsecase(repository: sl.call()));
  sl.registerLazySingleton(() => UpdateUserUsecase(repository: sl.call()));
  sl.registerLazySingleton(() => GetUserUsecase(repository: sl.call()));
  sl.registerLazySingleton(() => CreateUserUsecase(repository: sl.call()));
  sl.registerLazySingleton(() => GetSingleUserUsecase(repository: sl.call()));

  // post usecases
  sl.registerLazySingleton(() => CreatePostUsecase(repository: sl.call()));
  sl.registerLazySingleton(() => DeletePostUsecase(repository: sl.call()));
  sl.registerLazySingleton(() => UpdatePostUsecase(repository: sl.call()));
  sl.registerLazySingleton(() => LikePostUsecase(repository: sl.call()));
  sl.registerLazySingleton(() => FetchPostUsecase(repository: sl.call()));
  sl.registerLazySingleton(() => FetchSinglePostUsecase(repository: sl.call()));
  sl.registerLazySingleton(() => FetchPostByUid(repository: sl.call()));

  // comment usecases
  sl.registerLazySingleton(() => CreateCommentUsecase(repository: sl.call()));
  sl.registerLazySingleton(() => DeleteCommentUsecase(repository: sl.call()));
  sl.registerLazySingleton(() => UpdateCommentUsecase(repository: sl.call()));
  sl.registerLazySingleton(() => LikeCommentUsecase(repository: sl.call()));
  sl.registerLazySingleton(() => FetchCommentUsecase(repository: sl.call()));

  // repository

  sl.registerLazySingleton<FirebaseRepository>(
      () => FirebaseRepositoryImpl(remoteDataSource: sl.call()));
  sl.registerLazySingleton<RemoteDataSource>(() => RemoteDataSourceImpl(
      firebaseFirestore: sl.call(), firebaseAuth: sl.call()));

  // external

  final firebaseFirestore = FirebaseFirestore.instance;
  final firebaseAuth = FirebaseAuth.instance;

  sl.registerLazySingleton(() => firebaseFirestore);
  sl.registerLazySingleton(() => firebaseAuth);
}
