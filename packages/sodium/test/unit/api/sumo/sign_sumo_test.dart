import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/sign.dart';
import 'package:sodium/src/api/sumo/sign_sumo.dart';
import 'package:test/test.dart';

import '../../../secure_key_fake.dart';
import '../../../test_validator.dart';

class MockSign extends Mock with SignValidations implements Sign {}

class MockSignSumo extends MockSign
    with SignSumoValidations
    implements SignSumo {}

void main() {
  group('SignSumoValidations', () {
    late MockSignSumo sutMock;

    setUp(() {
      sutMock = MockSignSumo();
    });

    testCheckIsAny2(
      'validateSecretKeyOrSeed',
      source1: () => sutMock.secretKeyBytes,
      source2: () => sutMock.seedBytes,
      sut: (value) =>
          sutMock.validateSecretKeyOrSeed(SecureKeyFake.empty(value)),
    );
  });
}
