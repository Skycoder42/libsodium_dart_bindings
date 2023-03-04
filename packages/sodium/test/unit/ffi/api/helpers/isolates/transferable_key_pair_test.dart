@TestOn('dart-vm')
library transferable_key_pair_test;

import 'dart:isolate';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/key_pair.dart';
import 'package:sodium/src/api/secure_key.dart';
import 'package:sodium/src/ffi/api/helpers/isolates/transferable_key_pair.dart';
import 'package:sodium/src/ffi/api/secure_key_ffi.dart';
import 'package:sodium/src/ffi/api/sodium_ffi.dart';
import 'package:test/test.dart';

class MockSodiumFFI extends Mock implements SodiumFFI {}

class FakeSecureKey extends Fake implements SecureKey {
  final Uint8List bytes;

  FakeSecureKey(this.bytes);

  @override
  Uint8List extractBytes() => bytes;
}

class FakeSecureKeyFFI extends Fake implements SecureKeyFFI {
  @override
  final SecureKeyFFINativeHandle nativeHandle;

  FakeSecureKeyFFI(this.nativeHandle);
}

void main() {
  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  group('$TransferableKeyPair', () {
    final testPublicKey = Uint8List.fromList(List.filled(64, 0x42));
    final testFfiSecretKey = FakeSecureKeyFFI([0x12345678, 32]);
    final testGenericSecretKey =
        FakeSecureKey(Uint8List.fromList(List.generate(32, (index) => index)));
    final testFfiKeyPair = KeyPair(
      publicKey: testPublicKey,
      secretKey: testFfiSecretKey,
    );
    final testGenericKeyPair = KeyPair(
      publicKey: testPublicKey,
      secretKey: testGenericSecretKey,
    );

    final mockSodiumFFI = MockSodiumFFI();

    setUp(() {
      reset(mockSodiumFFI);
    });

    test('can wrap ffi secure key for transfer', () {
      final sut = TransferableKeyPair(testFfiKeyPair);
      sut.maybeWhen(
        ffi: (publicKeyBytes, secretKeyNativeHandle) {
          expect(publicKeyBytes.materialize().asUint8List(), testPublicKey);
          expect(secretKeyNativeHandle, testFfiSecretKey.nativeHandle);
        },
        orElse: () => fail(sut.toString()),
      );
    });

    test('can wrap generic secure key for transfer', () {
      final sut = TransferableKeyPair(testGenericKeyPair);
      sut.maybeWhen(
        generic: (publicKeyBytes, secretKeyBytes) {
          expect(publicKeyBytes.materialize().asUint8List(), testPublicKey);
          expect(
            secretKeyBytes.materialize().asUint8List(),
            testGenericSecretKey.bytes,
          );
        },
        orElse: () => fail(sut.toString()),
      );
    });

    test('can reconstruct an ffi key', () {
      when(() => mockSodiumFFI.secureHandle(any()))
          .thenReturn(testFfiSecretKey);

      final result = TransferableKeyPair.ffi(
        publicKeyBytes: TransferableTypedData.fromList([testPublicKey]),
        secretKeyNativeHandle: testFfiSecretKey.nativeHandle,
      ).toKeyPair(mockSodiumFFI);

      expect(result.publicKey, testPublicKey);
      expect(result.secretKey, same(testFfiSecretKey));

      verify(() => mockSodiumFFI.secureHandle(testFfiSecretKey.nativeHandle));
    });

    test('can reconstruct a generic key', () {
      when(() => mockSodiumFFI.secureCopy(any()))
          .thenReturn(testGenericSecretKey);

      final result = TransferableKeyPair.generic(
        publicKeyBytes: TransferableTypedData.fromList([testPublicKey]),
        secretKeyBytes: TransferableTypedData.fromList(
          [testGenericSecretKey.bytes],
        ),
      ).toKeyPair(mockSodiumFFI);

      expect(result.publicKey, testPublicKey);
      expect(result.secretKey, same(testGenericSecretKey));

      verify(() => mockSodiumFFI.secureCopy(testGenericSecretKey.bytes));
    });
  });
}
