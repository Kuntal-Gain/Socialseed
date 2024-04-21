import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:socialseed/data/data_source/remote_datasource.dart';
import 'package:socialseed/data/data_source/remote_datasource_impl.dart';
import 'package:socialseed/domain/entities/user_entity.dart';

import 'package:get_it/get_it.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockRemoteDataSource extends Mock implements RemoteDataSource {}

void main() {
  final sl = GetIt.instance;

  group('RemoteDataSourceImpl', () {
    late RemoteDataSourceImpl dataSource;
    late MockFirebaseAuth mockFirebaseAuth;
    late MockFirebaseFirestore mockFirebaseFirestore;
    late MockRemoteDataSource mockRemoteDataSource;

    setUp(() {
      mockFirebaseFirestore = MockFirebaseFirestore();
      mockFirebaseAuth = MockFirebaseAuth();
      mockRemoteDataSource = MockRemoteDataSource();
      dataSource = RemoteDataSourceImpl(
        firebaseAuth: mockFirebaseAuth,
        firebaseFirestore: mockFirebaseFirestore,
      );

      sl.registerSingleton<FirebaseAuth>(mockFirebaseAuth);
      sl.registerSingleton<FirebaseFirestore>(mockFirebaseFirestore);
      sl.registerSingleton<RemoteDataSource>(mockRemoteDataSource);
    });

    group('createUser', () {
      test('should create user in Firestore', () async {
        // arrange
        final user = UserEntity(
          uid: '123',
          username: 'test_user',
          fullname: 'Test User',
          email: 'test@example.com',
          bio: 'Test bio',
          imageUrl: 'test_image_url',
          friends: [],
          milestones: [],
          likedPages: [],
          posts: [],
          joinedDate: Timestamp.now(),
          isVerified: false,
          badges: [],
          followerCount: 0,
          followingCount: 0,
          stories: [],
        );

        // act
        await dataSource.createUser(user);

        // assert
        verify(mockRemoteDataSource.createUser(user));
      });
    });
  });
}
