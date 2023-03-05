@TestOn('dart-vm')
library isolate_result_test;

import 'dart:isolate';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/key_pair.dart';
import 'package:sodium/src/api/secure_key.dart';
import 'package:sodium/src/ffi/api/helpers/isolates/isolate_result.dart';
import 'package:sodium/src/ffi/api/helpers/isolates/transferable_key_pair.dart';
import 'package:sodium/src/ffi/api/helpers/isolates/transferable_secure_key.dart';
import 'package:sodium/src/ffi/api/sodium_ffi.dart';
import 'package:test/test.dart';

class MockSodiumFFI extends Mock implements SodiumFFI {}

class FakeSecureKey extends Fake implements SecureKey {}

class FakeKeyPair extends Fake implements KeyPair {}

void main() {
  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  group('$IsolateResult', () {
    final mockSodiumFFI = MockSodiumFFI();

    setUp(() {
      reset(mockSodiumFFI);
    });

    test('asserts when constructed with a subclass type of SecureKey', () {
      expect(
        () => IsolateResult<FakeSecureKey>.key(
          TransferableSecureKey.generic(TransferableTypedData.fromList([])),
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('asserts when constructed with a subclass type of KeyPair', () {
      expect(
        () => IsolateResult<FakeKeyPair>.keyPair(
          TransferableKeyPair.generic(
            publicKeyBytes: TransferableTypedData.fromList([]),
            secretKeyBytes: TransferableTypedData.fromList([]),
          ),
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    group('extract', () {
      test('returns simple transported value', () {
        const sut = IsolateResult(42);

        expect(sut.extract(mockSodiumFFI), 42);
      });

      test('returns transported secure key', () {
        final testData = Uint8List.fromList(List.filled(10, 10));
        final testSecureKey = FakeSecureKey();
        when(() => mockSodiumFFI.secureCopy(any())).thenReturn(testSecureKey);

        final sut = IsolateResult<SecureKey>.key(
          TransferableSecureKey.generic(
            TransferableTypedData.fromList([testData]),
          ),
        );

        expect(sut.extract(mockSodiumFFI), same(testSecureKey));

        verify(() => mockSodiumFFI.secureCopy(testData));
      });

      test('returns transported key pair', () {
        final testPublicKey = Uint8List.fromList(List.filled(10, 10));
        final testSecretData = Uint8List.fromList(List.filled(10, 10));
        final testSecureKey = FakeSecureKey();
        when(() => mockSodiumFFI.secureCopy(any())).thenReturn(testSecureKey);

        final sut = IsolateResult<KeyPair>.keyPair(
          TransferableKeyPair.generic(
            publicKeyBytes: TransferableTypedData.fromList([testPublicKey]),
            secretKeyBytes: TransferableTypedData.fromList([testSecretData]),
          ),
        );

        final result = sut.extract(mockSodiumFFI);
        expect(result.publicKey, testPublicKey);
        expect(result.secretKey, same(testSecureKey));

        verify(() => mockSodiumFFI.secureCopy(testSecretData));
      });
    });
  });
}
