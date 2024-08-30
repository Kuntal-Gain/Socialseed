import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:socialseed/domain/usecases/user/get_current_uid_usecase.dart';

import '../../../helpers/test_helper.mocks.dart';

void main() {
  late GetCurrentUidUsecase getCurrentUidUsecase;
  late MockFirebaseRepository mockFirebaseRepository;

  setUp(() {
    mockFirebaseRepository = MockFirebaseRepository();
    getCurrentUidUsecase =
        GetCurrentUidUsecase(repository: mockFirebaseRepository);
  });

  const testUid = 'TEST123';

  test('get current uid from repo', () async {
    //arrange
    when(mockFirebaseRepository.getCurrentUid())
        .thenAnswer((_) async => testUid);
    // act
    final result = await getCurrentUidUsecase.call();
    //assert
    expect(result, testUid);
    verify(mockFirebaseRepository.getCurrentUid()).called(1);
    verifyNoMoreInteractions(mockFirebaseRepository);
  });

  test('failed to get uid', () async {
    // arrange
    when(mockFirebaseRepository.getCurrentUid())
        .thenThrow(Exception('Failed to get UID'));
    // act
    expect(() => getCurrentUidUsecase.call(), throwsException);
    // assert
    verify(mockFirebaseRepository.getCurrentUid()).called(1);
    verifyNoMoreInteractions(mockFirebaseRepository);
  });
}
