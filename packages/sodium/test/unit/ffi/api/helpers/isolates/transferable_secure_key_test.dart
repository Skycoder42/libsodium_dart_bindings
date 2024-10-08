// ignore_for_file: unnecessary_lambdas

@TestOn('dart-vm')
library;

import 'dart:ffi';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/secure_key.dart';
import 'package:sodium/src/ffi/api/helpers/isolates/transferrable_secure_key_ffi.dart';
import 'package:sodium/src/ffi/api/secure_key_ffi.dart';
import 'package:sodium/src/ffi/api/sodium_ffi.dart';
import 'package:sodium/src/ffi/bindings/libsodium.ffi.dart';
import 'package:sodium/src/ffi/bindings/sodium_finalizer.dart';
import 'package:sodium/src/ffi/bindings/sodium_pointer.dart';
import 'package:test/test.dart';

import '../../../pointer_test_helpers.dart';

class MockLibSodiumFFI extends Mock implements LibSodiumFFI {}

class MockSodiumFinalizer extends Mock implements SodiumFinalizer {}

class MockSodiumFFI extends Mock implements SodiumFFI {}

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

  group('$TransferrableSecureKeyFFI', () {
    const testNativeHandle = (1234, 56);
    final testFfiKeyMock1 = MockSecureKeyFFI();
    final testFfiKeyMock2 = MockSecureKeyFFI();
    final testGenericKey =
        FakeSecureKey(Uint8List.fromList(List.generate(32, (index) => index)));

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
      final sut = TransferrableSecureKeyFFI(testFfiKeyMock1);
      sut.maybeWhen(
        ffi: (nativeHandle) {
          expect(nativeHandle, testNativeHandle);
        },
        orElse: () => fail(sut.toString()),
      );

      verifyInOrder([
        () => testFfiKeyMock1.copy(),
        () => testFfiKeyMock2.detach(),
      ]);
    });

    test('can wrap generic secure key for transfer', () {
      final sut = TransferrableSecureKeyFFI(testGenericKey);
      sut.maybeWhen(
        generic: (keyBytes) {
          expect(keyBytes.materialize().asUint8List(), testGenericKey.bytes);
        },
        orElse: () => fail(sut.toString()),
      );
    });

    test('can reconstruct an ffi key', () {
      when(() => mockLibSodiumFFI.sodium_mprotect_noaccess(any()))
          .thenReturn(0);

      final result = const TransferrableSecureKeyFFI.ffi(testNativeHandle)
          .toSecureKey(mockSodiumFFI) as SecureKeyFFI;

      verifyInOrder([
        () => mockSodiumFinalizer.attach(
              any(),
              Pointer.fromAddress(testNativeHandle.$1),
              testNativeHandle.$2,
            ),
        () => mockLibSodiumFFI.sodium_mprotect_noaccess(
              Pointer.fromAddress(testNativeHandle.$1),
            ),
      ]);

      expect(result.detach(), testNativeHandle);
    });

    test('can reconstruct a generic key', () {
      when(() => mockSodiumFFI.secureCopy(any())).thenReturn(testGenericKey);

      final result = TransferrableSecureKeyFFI.generic(
        TransferableTypedData.fromList([testGenericKey.bytes]),
      ).toSecureKey(mockSodiumFFI);

      expect(result, same(testGenericKey));

      verify(() => mockSodiumFFI.secureCopy(testGenericKey.bytes));
    });
  });
}
