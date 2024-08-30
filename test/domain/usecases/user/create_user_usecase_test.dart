import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:socialseed/domain/entities/user_entity.dart';
import 'package:socialseed/domain/usecases/user/create_user_usecase.dart';

import '../../../helpers/test_helper.mocks.dart';

void main() {
  late CreateUserUsecase createUserUsecase;
  late MockFirebaseRepository mockFirebaseRepository;

  setUp(() {
    mockFirebaseRepository = MockFirebaseRepository();
    createUserUsecase = CreateUserUsecase(repository: mockFirebaseRepository);
  });

  var testUser = UserEntity(
    username: "TEST",
    fullname: "TEST",
    email: "TEST@GMAIL.COM",
    password: "TEST123",
    bio: "",
    imageUrl: "",
    friends: const [],
    milestones: const [],
    likedPages: const [],
    posts: const [],
    joinedDate: Timestamp.now(),
    isVerified: false,
    badges: const [],
    followerCount: 0,
    followingCount: 0,
    stories: const [],
    imageFile: null,
    work: "",
    college: "",
    school: "",
    location: "",
    coverImage: "",
    dob: Timestamp.fromDate(DateTime(2000, 1, 1)),
    followers: const [],
    following: const [],
    requests: const [],
    activeStatus: true,
  );

  test('create test user', () async {
    // Arrange: Set up the mock behavior.
    when(mockFirebaseRepository.createUser(testUser))
        .thenAnswer((_) async => Future.value());

    // Act: Call the use case.
    await createUserUsecase.call(testUser);

    // Assert: Verify that the repository's createUser method was called with the correct arguments.
    verify(mockFirebaseRepository.createUser(testUser)).called(1);
  });
}
