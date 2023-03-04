@TestOn('dart-vm')
library transferable_secure_key_test;

import 'dart:isolate';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/secure_key.dart';
import 'package:sodium/src/ffi/api/helpers/isolates/transferable_secure_key.dart';
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

  group('$TransferableSecureKey', () {
    final testFfiKey = FakeSecureKeyFFI([0x12345678, 32]);
    final testGenericKey =
        FakeSecureKey(Uint8List.fromList(List.generate(32, (index) => index)));

    final mockSodiumFFI = MockSodiumFFI();

    setUp(() {
      reset(mockSodiumFFI);
    });

    test('can wrap ffi secure key for transfer', () {
      final sut = TransferableSecureKey(testFfiKey);
      sut.maybeWhen(
        ffi: (nativeHandle) {
          expect(nativeHandle, testFfiKey.nativeHandle);
        },
        orElse: () => fail(sut.toString()),
      );
    });

    test('can wrap generic secure key for transfer', () {
      final sut = TransferableSecureKey(testGenericKey);
      sut.maybeWhen(
        generic: (keyBytes) {
          expect(keyBytes.materialize().asUint8List(), testGenericKey.bytes);
        },
        orElse: () => fail(sut.toString()),
      );
    });

    test('can reconstruct an ffi key', () {
      when(() => mockSodiumFFI.secureHandle(any())).thenReturn(testFfiKey);

      final result = TransferableSecureKey.ffi(testFfiKey.nativeHandle)
          .toSecureKey(mockSodiumFFI);

      expect(result, same(testFfiKey));

      verify(() => mockSodiumFFI.secureHandle(testFfiKey.nativeHandle));
    });

    test('can reconstruct a generic key', () {
      when(() => mockSodiumFFI.secureCopy(any())).thenReturn(testGenericKey);

      final result = TransferableSecureKey.generic(
        TransferableTypedData.fromList([testGenericKey.bytes]),
      ).toSecureKey(mockSodiumFFI);

      expect(result, same(testGenericKey));

      verify(() => mockSodiumFFI.secureCopy(testGenericKey.bytes));
    });
  });
}
