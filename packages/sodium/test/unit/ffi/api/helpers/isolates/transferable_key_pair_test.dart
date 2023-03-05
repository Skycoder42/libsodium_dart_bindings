// ignore_for_file: unnecessary_lambdas

@TestOn('dart-vm')
library transferable_key_pair_test;

import 'dart:ffi';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/key_pair.dart';
import 'package:sodium/src/api/secure_key.dart';
import 'package:sodium/src/ffi/api/helpers/isolates/transferable_key_pair.dart';
import 'package:sodium/src/ffi/api/secure_key_ffi.dart';
import 'package:sodium/src/ffi/api/sodium_ffi.dart';
import 'package:sodium/src/ffi/bindings/libsodium.ffi.dart';
import 'package:sodium/src/ffi/bindings/sodium_finalizer.dart';
import 'package:sodium/src/ffi/bindings/sodium_pointer.dart';
import 'package:test/test.dart';

import '../../../pointer_test_helpers.dart';

class MockSodiumFFI extends Mock implements SodiumFFI {}

class MockLibSodiumFFI extends Mock implements LibSodiumFFI {}

class MockSodiumFinalizer extends Mock implements SodiumFinalizer {}

class FakeSecureKey extends Fake implements SecureKey {
  final Uint8List bytes;

  FakeSecureKey(this.bytes);

  @override
  Uint8List extractBytes() => bytes;
}

class MockSecureKeyFFI extends Mock implements SecureKeyFFI {}

void main() {
  setUpAll(() {
    registerPointers();
    registerFallbackValue(Uint8List(0));
  });

  group('$TransferableKeyPair', () {
    final testPublicKey = Uint8List.fromList(List.filled(64, 0x42));
    const testNativeHandle = [1234, 56];
    final testFfiKeyMock1 = MockSecureKeyFFI();
    final testFfiKeyMock2 = MockSecureKeyFFI();
    final testGenericSecretKey =
        FakeSecureKey(Uint8List.fromList(List.generate(32, (index) => index)));
    final testFfiKeyPair = KeyPair(
      publicKey: testPublicKey,
      secretKey: testFfiKeyMock1,
    );
    final testGenericKeyPair = KeyPair(
      publicKey: testPublicKey,
      secretKey: testGenericSecretKey,
    );

    final mockSodiumFFI = MockSodiumFFI();
    final mockLibSodiumFFI = MockLibSodiumFFI();
    final mockSodiumFinalizer = MockSodiumFinalizer();

    setUp(() {
      reset(testFfiKeyMock1);
      reset(testFfiKeyMock2);
      reset(mockSodiumFFI);
      reset(mockLibSodiumFFI);
      reset(mockSodiumFinalizer);

      when(() => testFfiKeyMock1.copy()).thenReturn(testFfiKeyMock2);
      when(() => testFfiKeyMock2.detach()).thenReturn(testNativeHandle);

      when(() => mockSodiumFFI.sodium).thenReturn(mockLibSodiumFFI);
      SodiumPointer.debugOverwriteFinalizer(
        mockLibSodiumFFI,
        mockSodiumFinalizer,
      );
    });

    test('can wrap ffi secure key for transfer', () {
      final sut = TransferableKeyPair(testFfiKeyPair);
      sut.maybeWhen(
        ffi: (publicKeyBytes, secretKeyNativeHandle) {
          expect(publicKeyBytes.materialize().asUint8List(), testPublicKey);
          expect(secretKeyNativeHandle, testNativeHandle);
        },
        orElse: () => fail(sut.toString()),
      );

      verifyInOrder([
        () => testFfiKeyMock1.copy(),
        () => testFfiKeyMock2.detach(),
      ]);
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
      when(() => mockLibSodiumFFI.sodium_mprotect_noaccess(any()))
          .thenReturn(0);

      final result = TransferableKeyPair.ffi(
        publicKeyBytes: TransferableTypedData.fromList([testPublicKey]),
        secretKeyNativeHandle: testNativeHandle,
      ).toKeyPair(mockSodiumFFI);

      verifyInOrder([
        () => mockSodiumFinalizer.attach(
              any(),
              Pointer.fromAddress(testNativeHandle[0]),
            ),
        () => mockLibSodiumFFI.sodium_mprotect_noaccess(
              Pointer.fromAddress(testNativeHandle[0]),
            )
      ]);

      expect(result.publicKey, testPublicKey);
      expect((result.secretKey as SecureKeyFFI).detach(), testNativeHandle);
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
