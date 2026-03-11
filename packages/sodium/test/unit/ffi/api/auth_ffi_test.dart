// ignore_for_file: unnecessary_lambdas for mocking

@TestOn('dart-vm')
library;

import 'dart:ffi';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/ffi/api/auth_ffi.dart';
import 'package:sodium/src/ffi/bindings/libsodium.ffi.wrapper.dart';
import 'package:test/test.dart';

import '../../../secure_key_fake.dart';
import '../../../test_constants_mapping.dart';
import '../keygen_test_helpers.dart';
import '../pointer_test_helpers.dart';

class MockSodiumFFI extends Mock implements LibSodiumFFI {}

void main() {
  final mockSodium = MockSodiumFFI();

  late AuthFFI sut;

  setUpAll(() {
    registerPointers();
  });

  setUp(() {
    reset(mockSodium);

    mockAllocArray(mockSodium);

    sut = AuthFFI(mockSodium);
  });

  testConstantsMapping([
    (() => mockSodium.crypto_auth_bytes(), () => sut.bytes, 'bytes'),
    (() => mockSodium.crypto_auth_keybytes(), () => sut.keyBytes, 'keyBytes'),
  ]);

  group('methods', () {
    setUp(() {
      when(() => mockSodium.crypto_auth_bytes()).thenReturn(5);
      when(() => mockSodium.crypto_auth_keybytes()).thenReturn(5);
    });

    testKeygen(
      mockSodium: mockSodium,
      runKeygen: () => sut.keygen(),
      keyBytesNative: mockSodium.crypto_auth_keybytes,
      keygenNative: mockSodium.crypto_auth_keygen,
    );

    group('call', () {
      test('asserts if key is invalid', () {
        expect(
          () => sut(message: Uint8List(0), key: SecureKeyFake.empty(10)),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_auth_keybytes());
      });

      test('calls crypto_auth with correct arguments', () {
        when(
          () => mockSodium.crypto_auth(any(), any(), any(), any()),
        ).thenReturn(0);

        final message = List.generate(20, (index) => index * 2);
        final key = List.generate(5, (index) => index);

        sut(message: Uint8List.fromList(message), key: SecureKeyFake(key));

        verifyInOrder([
          () => mockSodium.sodium_mprotect_readonly(
            any(that: hasRawData(message)),
          ),
          () => mockSodium.sodium_allocarray(5, 1),
          () => mockSodium.sodium_mprotect_readonly(any(that: hasRawData(key))),
          () => mockSodium.crypto_auth(
            any(that: isNot(nullptr)),
            any(that: hasRawData<UnsignedChar>(message)),
            message.length,
            any(that: hasRawData<UnsignedChar>(key)),
          ),
        ]);
      });

      test('returns authentication tag', () {
        final tag = List.generate(5, (index) => 10 + index);
        when(
          () => mockSodium.crypto_auth(any(), any(), any(), any()),
        ).thenAnswer((i) {
          fillPointer(
            i.positionalArguments.first as Pointer<UnsignedChar>,
            tag,
          );
          return 0;
        });

        final result = sut(message: Uint8List(10), key: SecureKeyFake.empty(5));

        expect(result, tag);

        verify(() => mockSodium.sodium_free(any())).called(2);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_auth(any(), any(), any(), any()),
        ).thenReturn(1);

        expect(
          () => sut(message: Uint8List(15), key: SecureKeyFake.empty(5)),
          throwsA(isA<SodiumException>()),
        );

        verify(() => mockSodium.sodium_free(any())).called(3);
      });
    });

    group('verify', () {
      test('asserts if tag is invalid', () {
        expect(
          () => sut.verify(
            tag: Uint8List(10),
            message: Uint8List(0),
            key: SecureKeyFake.empty(5),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_auth_bytes());
      });

      test('asserts if key is invalid', () {
        expect(
          () => sut.verify(
            tag: Uint8List(5),
            message: Uint8List(0),
            key: SecureKeyFake.empty(10),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_auth_keybytes());
      });

      test('calls crypto_auth_verify with correct arguments', () {
        when(
          () => mockSodium.crypto_auth_verify(any(), any(), any(), any()),
        ).thenReturn(0);

        final tag = List.generate(5, (index) => index + 15);
        final message = List.generate(20, (index) => index * 2);
        final key = List.generate(5, (index) => index);

        sut.verify(
          tag: Uint8List.fromList(tag),
          message: Uint8List.fromList(message),
          key: SecureKeyFake(key),
        );

        verifyInOrder([
          () => mockSodium.sodium_mprotect_readonly(any(that: hasRawData(tag))),
          () => mockSodium.sodium_mprotect_readonly(
            any(that: hasRawData(message)),
          ),
          () => mockSodium.sodium_mprotect_readonly(any(that: hasRawData(key))),
          () => mockSodium.crypto_auth_verify(
            any(that: hasRawData<UnsignedChar>(tag)),
            any(that: hasRawData<UnsignedChar>(message)),
            message.length,
            any(that: hasRawData<UnsignedChar>(key)),
          ),
        ]);
      });

      test('returns true if validate succeeds', () {
        when(
          () => mockSodium.crypto_auth_verify(any(), any(), any(), any()),
        ).thenReturn(0);

        final result = sut.verify(
          tag: Uint8List(5),
          message: Uint8List(22),
          key: SecureKeyFake.empty(5),
        );

        expect(result, isTrue);

        verify(() => mockSodium.sodium_free(any())).called(3);
      });

      test('returns false if validate fails', () {
        when(
          () => mockSodium.crypto_auth_verify(any(), any(), any(), any()),
        ).thenReturn(1);

        final result = sut.verify(
          tag: Uint8List(5),
          message: Uint8List(22),
          key: SecureKeyFake.empty(5),
        );

        expect(result, isFalse);

        verify(() => mockSodium.sodium_free(any())).called(3);
      });
    });
  });
}
