import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:socialseed/domain/entities/user_entity.dart';
import 'package:socialseed/domain/usecases/user/sign_in_usecase.dart';

import '../../../helpers/test_helper.mocks.dart';

void main() {
  late SignInUsecase signInUsecase;
  late MockFirebaseRepository mockFirebaseRepository;

  setUp(() {
    mockFirebaseRepository = MockFirebaseRepository();

    signInUsecase = SignInUsecase(repository: mockFirebaseRepository);
  });

  var testUser = UserEntity(
    email: "test@mail.com",
    password: "test123",
  );

  test('should sign in the user through the repository', () async {
    // Arrange: Set up the expected behavior
    when(mockFirebaseRepository.signInUser(testUser))
        .thenAnswer((_) async => Future.value());

    // Act: Call the use case
    await signInUsecase.call(testUser);

    // Assert: Verify that the repository's signInUser method was called with the correct arguments
    verify(mockFirebaseRepository.signInUser(testUser)).called(1);
    verifyNoMoreInteractions(mockFirebaseRepository);
  });

  test('should throw an exception if signInUser fails', () async {
    // Arrange: Set up the expected behavior to throw an exception
    when(mockFirebaseRepository.signInUser(testUser))
        .thenThrow(Exception('Sign-in failed'));

    // Act: Call the use case and expect an exception
    expect(() => signInUsecase.call(testUser), throwsException);

    // Assert: Verify that the repository's signInUser method was called
    verify(mockFirebaseRepository.signInUser(testUser)).called(1);
    verifyNoMoreInteractions(mockFirebaseRepository);
  });
}
