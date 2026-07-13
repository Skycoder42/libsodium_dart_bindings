// ignore_for_file: unnecessary_lambdas for mocking

import 'dart:typed_data';

import 'package:dart_test_tools/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/kdf_hkdf.dart';
import 'package:test/test.dart';

import '../../secure_key_fake.dart';
import '../../test_validator.dart';

class MockKdfHkdf extends Mock with KdfHkdfValidations implements KdfHkdf {}

class MockKdfHkdfExtractConsumer extends Mock
    implements KdfHkdfExtractConsumer {}

void main() {
  setUpAll(() {
    registerFallbackValue(const Stream<Uint8List>.empty());
  });

  group('KdfHkdfValidations', () {
    late MockKdfHkdf sutMock;

    setUp(() {
      sutMock = MockKdfHkdf();
    });

    testCheckIsSame(
      'validateMasterKey',
      source: () => sutMock.keyBytes,
      sut: (value) => sutMock.validateMasterKey(SecureKeyFake.empty(value)),
    );

    testCheckInRange(
      'validateOutLen',
      minSource: () => sutMock.bytesMin,
      maxSource: () => sutMock.bytesMax,
      sut: (value) => sutMock.validateOutLen(value),
    );

    test('extractStream pipes input keying material into consumer', () async {
      final mockConsumer = MockKdfHkdfExtractConsumer();

      const ikmStream = Stream<Uint8List>.empty();
      final salt = Uint8List.fromList(List.generate(8, (index) => index));
      final masterKey = SecureKeyFake(List.generate(15, (index) => index));

      when(
        () => sutMock.createExtractConsumer(salt: any(named: 'salt')),
      ).thenReturn(mockConsumer);
      when(() => mockConsumer.addStream(any())).thenReturnAsync(null);
      when(() => mockConsumer.close()).thenReturnAsync(masterKey);

      final res = await sutMock.extractStream(salt: salt, ikm: ikmStream);

      expect(res, masterKey);
      verifyInOrder([
        () => sutMock.createExtractConsumer(salt: salt),
        () => mockConsumer.addStream(ikmStream),
        () => mockConsumer.close(),
      ]);
    });
  });
}
