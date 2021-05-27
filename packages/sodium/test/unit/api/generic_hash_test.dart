import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/generic_hash.dart';
import 'package:test/test.dart';

import '../../secure_key_fake.dart';
import '../../test_validator.dart';

class MockGenericHash extends Mock
    with GenericHashValidations
    implements GenericHash {}

class MockGenericHashConsumer extends Mock implements GenericHashConsumer {}

void main() {
  setUpAll(() {
    registerFallbackValue(const Stream<Uint8List>.empty());
  });

  group('GenericHashValidations', () {
    late MockGenericHash sutMock;

    setUp(() {
      sutMock = MockGenericHash();
    });

    testCheckInRange(
      'validateOutLen',
      minSource: () => sutMock.bytesMin,
      maxSource: () => sutMock.bytesMax,
      sut: (value) => sutMock.validateOutLen(value),
    );

    testCheckInRange(
      'validateKey',
      minSource: () => sutMock.keyBytesMin,
      maxSource: () => sutMock.keyBytesMax,
      sut: (value) => sutMock.validateKey(SecureKeyFake.empty(value)),
    );

    test('stream pipes messages into consumer', () async {
      final mockConsumer = MockGenericHashConsumer();

      const messageStream = Stream<Uint8List>.empty();
      const outLen = 42;
      final key = SecureKeyFake(
        List.generate(15, (index) => index),
      );
      final hash = Uint8List.fromList(
        List.generate(5, (index) => 100 + index),
      );

      when(() => sutMock.createConsumer(
            outLen: any(named: 'outLen'),
            key: any(named: 'key'),
          )).thenReturn(mockConsumer);
      when<dynamic>(() => mockConsumer.addStream(any()))
          .thenAnswer((i) async {});
      when(() => mockConsumer.close()).thenAnswer((i) async => hash);

      final res = await sutMock.stream(
        messages: messageStream,
        outLen: outLen,
        key: key,
      );

      expect(res, hash);
      verifyInOrder([
        () => sutMock.createConsumer(
              outLen: outLen,
              key: key,
            ),
        () => mockConsumer.addStream(messageStream),
        () => mockConsumer.close(),
      ]);
    });
  });
}
