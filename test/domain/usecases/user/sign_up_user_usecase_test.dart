import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:socialseed/domain/entities/user_entity.dart';
import 'package:socialseed/domain/usecases/user/sign_in_usecase.dart';
import 'package:socialseed/domain/usecases/user/sign_up_usecase.dart';

import '../../../helpers/test_helper.mocks.dart';

void main() {
  late SignUpUsecase signUpUsecase;
  late MockFirebaseRepository mockFirebaseRepository;

  setUp(() {
    mockFirebaseRepository = MockFirebaseRepository();

    signUpUsecase = SignUpUsecase(repository: mockFirebaseRepository);
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

  test('should sign in the user through the repository', () async {
    // Arrange: Set up the expected behavior
    when(mockFirebaseRepository.signUpUser(testUser))
        .thenAnswer((_) async => Future.value());

    // Act: Call the use case
    await signUpUsecase.call(testUser);

    // Assert: Verify that the repository's signInUser method was called with the correct arguments
    verify(mockFirebaseRepository.signUpUser(testUser)).called(1);
    verifyNoMoreInteractions(mockFirebaseRepository);
  });

  test('should throw an exception if signInUser fails', () async {
    // Arrange: Set up the expected behavior to throw an exception
    when(mockFirebaseRepository.signUpUser(testUser))
        .thenThrow(Exception('Sign-in failed'));

    // Act: Call the use case and expect an exception
    expect(() => signUpUsecase.call(testUser), throwsException);

    // Assert: Verify that the repository's signInUser method was called
    verify(mockFirebaseRepository.signUpUser(testUser)).called(1);
    verifyNoMoreInteractions(mockFirebaseRepository);
  });
}
