import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/ipcrypt.dart';
import 'package:test/test.dart';

import '../../secure_key_fake.dart';
import '../../test_validator.dart';

class MockIpcrypt extends Mock with IpcryptValidations implements Ipcrypt {}

class MockIpcryptNd extends Mock
    with IpcryptNdValidations
    implements IpcryptNd {}

class MockIpcryptPfx extends Mock
    with IpcryptPfxValidations
    implements IpcryptPfx {}

void main() {
  group('IpcryptValidations', () {
    late MockIpcrypt sutMock;

    setUp(() {
      sutMock = MockIpcrypt();
    });

    testCheckIsSame(
      'validateInput',
      source: () => sutMock.bytes,
      sut: (value) => sutMock.validateInput(Uint8List(value)),
    );

    testCheckIsSame(
      'validateKey',
      source: () => sutMock.keyBytes,
      sut: (value) => sutMock.validateKey(SecureKeyFake.empty(value)),
    );
  });

  group('IpcryptNdValidations', () {
    late MockIpcryptNd sutMock;

    setUp(() {
      sutMock = MockIpcryptNd();
    });

    testCheckIsSame(
      'validateInput',
      source: () => sutMock.inputBytes,
      sut: (value) => sutMock.validateInput(Uint8List(value)),
    );

    testCheckIsSame(
      'validateTweak',
      source: () => sutMock.tweakBytes,
      sut: (value) => sutMock.validateTweak(Uint8List(value)),
    );

    testCheckIsSame(
      'validateKey',
      source: () => sutMock.keyBytes,
      sut: (value) => sutMock.validateKey(SecureKeyFake.empty(value)),
    );

    testCheckIsSame(
      'validateCiphertext',
      source: () => sutMock.outputBytes,
      sut: (value) => sutMock.validateCiphertext(Uint8List(value)),
    );
  });

  group('IpcryptPfxValidations', () {
    late MockIpcryptPfx sutMock;

    setUp(() {
      sutMock = MockIpcryptPfx();
    });

    testCheckIsSame(
      'validateInput',
      source: () => sutMock.bytes,
      sut: (value) => sutMock.validateInput(Uint8List(value)),
    );

    testCheckIsSame(
      'validateKey',
      source: () => sutMock.keyBytes,
      sut: (value) => sutMock.validateKey(SecureKeyFake.empty(value)),
    );
  });
}
