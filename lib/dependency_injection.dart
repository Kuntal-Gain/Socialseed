import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:socialseed/app/cubits/auth/auth_cubit.dart';

import 'package:socialseed/app/cubits/comment/cubit/comment_cubit.dart';
import 'package:socialseed/app/cubits/credential/credential_cubit.dart';
import 'package:socialseed/app/cubits/get_single_other_user/get_single_other_user_cubit.dart';
import 'package:socialseed/app/cubits/get_single_post/cubit/get_single_post_cubit.dart';
import 'package:socialseed/app/cubits/get_single_user/get_single_user_cubit.dart';
import 'package:socialseed/app/cubits/message/chat_id/chat_cubit.dart';
import 'package:socialseed/app/cubits/message/message_cubit.dart';
import 'package:socialseed/app/cubits/post/post_cubit.dart';
import 'package:socialseed/app/cubits/story/story_cubit.dart';
import 'package:socialseed/app/cubits/users/user_cubit.dart';
import 'package:socialseed/data/data_source/remote_datasource.dart';
import 'package:socialseed/data/data_source/remote_datasource_impl.dart';
import 'package:socialseed/data/repos/firebase_repository_impl.dart';
import 'package:socialseed/domain/repos/firebase_repository.dart';
import 'package:socialseed/domain/usecases/chat/create_messageid_usecase.dart';
import 'package:socialseed/domain/usecases/chat/fetch_conversations_usecase.dart';
import 'package:socialseed/domain/usecases/chat/fetch_message_usecase.dart';
import 'package:socialseed/domain/usecases/chat/is_messageid_exists_usecase.dart';
import 'package:socialseed/domain/usecases/chat/send_message_usecase.dart';
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
import 'package:socialseed/domain/usecases/story/add_story_usecase.dart';
import 'package:socialseed/domain/usecases/story/fetch_story_usecase.dart';
import 'package:socialseed/domain/usecases/story/view_story_usecase.dart';
import 'package:socialseed/domain/usecases/user/create_user_usecase.dart';
import 'package:socialseed/domain/usecases/user/get_current_uid_usecase.dart';
import 'package:socialseed/domain/usecases/user/get_single_user_usecase.dart';
import 'package:socialseed/domain/usecases/user/get_user_usecase.dart';
import 'package:socialseed/domain/usecases/user/is_signin_usecase.dart';
import 'package:socialseed/domain/usecases/user/sign_in_usecase.dart';
import 'package:socialseed/domain/usecases/user/sign_out_usecase.dart';
import 'package:socialseed/domain/usecases/user/sign_up_usecase.dart';
import 'package:socialseed/domain/usecases/user/update_user_status_usecase.dart';
import 'package:socialseed/domain/usecases/user/update_user_usecase.dart';
import 'package:socialseed/domain/usecases/user_controllers/accept_request_usecase.dart';
import 'package:socialseed/domain/usecases/user_controllers/follow_user_usecase.dart';
import 'package:socialseed/domain/usecases/user_controllers/reject_request_usecase.dart';
import 'package:socialseed/domain/usecases/user_controllers/send_request_usecase.dart';
import 'package:socialseed/features/services/internet_service.dart';

import 'domain/usecases/user/get_single_other_user_usecase.dart';
import 'domain/usecases/user_controllers/unfollow_user_usecase.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // cubits

  sl.registerFactory(
    () => AuthCubit(
      signOutUsecase: sl.call(),
      isSignInUsecase: sl.call(),
      getCurrentUidUsecase: sl.call(),
      updateUserStatusUsecase: sl.call(),
      service: sl.call(),
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
      acceptRequestUsecase: sl.call(),
      followUserUsecase: sl.call(),
      sendRequestUsecase: sl.call(),
      unFollowUserUsecase: sl.call(),
      rejectRequestUsecase: sl.call(),
      updateUserStatusUsecase: sl.call(),
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

  sl.registerFactory(() => MessageCubit(
        sendMessageUsecase: sl.call(),
        fetchMessageUsecase: sl.call(),
      ));

  sl.registerFactory(
    () => ChatCubit(
      createMessageWithId: sl.call(),
      fetchConversationUsecase: sl.call(),
      isMessageIdExistsUsecase: sl.call(),
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

  sl.registerFactory(
    () => GetSingleOtherUserCubit(
      getSingleOtherUserUseCase: sl.call(),
    ),
  );

  sl.registerFactory(
    () => StoryCubit(
      addStoryUsecase: sl.call(),
      viewStoryUsecase: sl.call(),
      fetchStoryUsecase: sl.call(),
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
  sl.registerLazySingleton(
      () => GetSingleOtherUserUseCase(repository: sl.call()));
  sl.registerLazySingleton(() => FollowUserUsecase(repository: sl.call()));
  sl.registerLazySingleton(() => UnFollowUserUsecase(repository: sl.call()));
  sl.registerLazySingleton(() => AcceptRequestUsecase(repository: sl.call()));
  sl.registerLazySingleton(() => RejectRequestUsecase(repository: sl.call()));
  sl.registerLazySingleton(() => SendRequestUsecase(repository: sl.call()));

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

  // message usecase
  sl.registerLazySingleton(() => SendMessageUsecase(repository: sl.call()));
  sl.registerLazySingleton(() => FetchMessageUsecase(repository: sl.call()));
  sl.registerLazySingleton(() => CreateMessageWithId(repository: sl.call()));
  sl.registerLazySingleton(
      () => FetchConversationUsecase(repository: sl.call()));
  sl.registerLazySingleton(
      () => IsMessageIdExistsUsecase(repository: sl.call()));

  // story usecase
  sl.registerLazySingleton(() => AddStoryUsecase(repository: sl.call()));
  sl.registerLazySingleton(() => FetchStoryUsecase(repository: sl.call()));
  sl.registerLazySingleton(() => ViewStoryUsecase(repository: sl.call()));

  //external
  sl.registerLazySingleton(
      () => UpdateUserStatusUsecase(repository: sl.call()));

  // repository

  sl.registerLazySingleton<FirebaseRepository>(
      () => FirebaseRepositoryImpl(remoteDataSource: sl.call()));
  sl.registerLazySingleton<RemoteDataSource>(
    () => RemoteDataSourceImpl(
      firebaseFirestore: sl.call(),
      firebaseAuth: sl.call(),
      connectivityService: sl.call(),
    ),
  );

  // external

  final firebaseFirestore = FirebaseFirestore.instance;
  final firebaseAuth = FirebaseAuth.instance;
  final internetService = ConnectivityService();

  sl.registerLazySingleton(() => firebaseFirestore);
  sl.registerLazySingleton(() => firebaseAuth);
  sl.registerLazySingleton(() => internetService);
}
