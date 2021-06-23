import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/kdf.dart';
import 'package:test/test.dart';

import '../../secure_key_fake.dart';
import '../../test_validator.dart';

class MockKdf extends Mock with KdfValidations implements Kdf {}

void main() {
  group('KdfValidations', () {
    late MockKdf sutMock;

    setUp(() {
      sutMock = MockKdf();
    });

    testCheckIsSame(
      'validateMasterKey',
      source: () => sutMock.keyBytes,
      sut: (value) => sutMock.validateMasterKey(SecureKeyFake.empty(value)),
    );

    testCheckAtMost(
      'validateContext',
      source: () => sutMock.contextBytes,
      sut: (value) => sutMock.validateContext('x' * value),
    );

    testCheckInRange(
      'validateSubkeyLen',
      minSource: () => sutMock.bytesMin,
      maxSource: () => sutMock.bytesMax,
      sut: (value) => sutMock.validateSubkeyLen(value),
    );
  });
}
