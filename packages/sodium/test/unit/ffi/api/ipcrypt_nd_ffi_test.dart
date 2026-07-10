// ignore_for_file: unnecessary_lambdas to catch member access errors

@TestOn('dart-vm')
library;

import 'dart:ffi';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/ffi/api/ip_address_ffi.dart';
import 'package:sodium/src/ffi/api/ipcrypt_nd_ffi.dart';
import 'package:sodium/src/ffi/bindings/libsodium.ffi.wrapper.dart';
import 'package:sodium/src/ffi/bindings/sodium_pointer.dart';
import 'package:test/test.dart';

import '../../../secure_key_fake.dart';
import '../../../test_constants_mapping.dart';
import '../keygen_test_helpers.dart';
import '../pointer_test_helpers.dart';

class MockSodiumFFI extends Mock implements LibSodiumFFI {}

void main() {
  final mockSodium = MockSodiumFFI();

  late IpcryptNdFFI sut;

  setUpAll(() {
    registerPointers();
  });

  setUp(() {
    reset(mockSodium);
    mockAllocArray(mockSodium);
    sut = IpcryptNdFFI(mockSodium);
  });

  testConstantsMapping([
    (
      () => mockSodium.crypto_ipcrypt_nd_keybytes(),
      () => sut.keyBytes,
      'keyBytes',
    ),
    (
      () => mockSodium.crypto_ipcrypt_nd_tweakbytes(),
      () => sut.tweakBytes,
      'tweakBytes',
    ),
    (
      () => mockSodium.crypto_ipcrypt_nd_inputbytes(),
      () => sut.inputBytes,
      'inputBytes',
    ),
    (
      () => mockSodium.crypto_ipcrypt_nd_outputbytes(),
      () => sut.outputBytes,
      'outputBytes',
    ),
  ]);

  group('methods', () {
    setUp(() {
      when(() => mockSodium.crypto_ipcrypt_nd_keybytes()).thenReturn(5);
      when(() => mockSodium.crypto_ipcrypt_nd_tweakbytes()).thenReturn(5);
      when(() => mockSodium.crypto_ipcrypt_nd_inputbytes()).thenReturn(16);
      when(() => mockSodium.crypto_ipcrypt_nd_outputbytes()).thenReturn(24);
    });

    testKeygen(
      mockSodium: mockSodium,
      runKeygen: () => sut.keygen(),
      keyBytesNative: mockSodium.crypto_ipcrypt_nd_keybytes,
      keygenNative: mockSodium.crypto_ipcrypt_nd_keygen,
    );

    group('encrypt', () {
      test('asserts if input is invalid', () {
        when(() => mockSodium.crypto_ipcrypt_nd_inputbytes()).thenReturn(17);

        final ptr = SodiumPointer<UnsignedChar>.alloc(mockSodium, count: 16);
        final input = IpAddressFFI.fromPointer(mockSodium, ptr);

        expect(
          () => sut.encrypt(
            input: input,
            tweak: Uint8List(5),
            key: SecureKeyFake.empty(5),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_ipcrypt_nd_inputbytes());
      });

      test('asserts if tweak is invalid', () {
        final ptr = SodiumPointer<UnsignedChar>.alloc(mockSodium, count: 16);
        final input = IpAddressFFI.fromPointer(mockSodium, ptr);

        expect(
          () => sut.encrypt(
            input: input,
            tweak: Uint8List(10),
            key: SecureKeyFake.empty(5),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_ipcrypt_nd_tweakbytes());
      });

      test('asserts if key is invalid', () {
        final ptr = SodiumPointer<UnsignedChar>.alloc(mockSodium, count: 16);
        final input = IpAddressFFI.fromPointer(mockSodium, ptr);

        expect(
          () => sut.encrypt(
            input: input,
            tweak: Uint8List(5),
            key: SecureKeyFake.empty(10),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_ipcrypt_nd_keybytes());
      });

      test('calls crypto_ipcrypt_nd_encrypt with correct arguments', () {
        when(
          () =>
              mockSodium.crypto_ipcrypt_nd_encrypt(any(), any(), any(), any()),
        ).thenAnswer((_) {});

        final ipData = List.generate(16, (i) => i);
        final ptr = SodiumPointer<UnsignedChar>.alloc(mockSodium, count: 16);
        fillPointer(ptr.ptr, ipData);
        final input = IpAddressFFI.fromPointer(mockSodium, ptr);
        final tweakData = List.generate(5, (i) => i + 30);
        final keyData = List.generate(5, (i) => i + 50);

        sut.encrypt(
          input: input,
          tweak: Uint8List.fromList(tweakData),
          key: SecureKeyFake(keyData),
        );

        verifyInOrder([
          () => mockSodium.crypto_ipcrypt_nd_encrypt(
            any(that: isNot(nullptr)),
            any(that: hasRawData<UnsignedChar>(ipData)),
            any(that: hasRawData<UnsignedChar>(tweakData)),
            any(that: hasRawData<UnsignedChar>(keyData)),
          ),
        ]);
      });

      test('returns encrypt result', () {
        final outData = List.generate(24, (i) => i + 10);

        when(
          () =>
              mockSodium.crypto_ipcrypt_nd_encrypt(any(), any(), any(), any()),
        ).thenAnswer((i) {
          fillPointer(
            i.positionalArguments[0] as Pointer<UnsignedChar>,
            outData,
          );
        });

        final ptr = SodiumPointer<UnsignedChar>.alloc(mockSodium, count: 16);
        final input = IpAddressFFI.fromPointer(mockSodium, ptr);

        final result = sut.encrypt(
          input: input,
          tweak: Uint8List(5),
          key: SecureKeyFake.empty(5),
        );

        expect(result, outData);

        // tweakPtr (finally) + key temp pointer = 2 frees
        verify(() => mockSodium.sodium_free(any())).called(2);
      });
    });

    group('decrypt', () {
      test('asserts if cipherText is invalid', () {
        expect(
          () => sut.decrypt(
            cipherText: Uint8List(10),
            key: SecureKeyFake.empty(5),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_ipcrypt_nd_outputbytes());
      });

      test('asserts if key is invalid', () {
        expect(
          () => sut.decrypt(
            cipherText: Uint8List(24),
            key: SecureKeyFake.empty(10),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_ipcrypt_nd_keybytes());
      });

      test('calls crypto_ipcrypt_nd_decrypt with correct arguments', () {
        when(
          () => mockSodium.crypto_ipcrypt_nd_decrypt(any(), any(), any()),
        ).thenAnswer((_) {});

        final ctData = List.generate(24, (i) => i + 5);
        final keyData = List.generate(5, (i) => i + 50);

        sut.decrypt(
          cipherText: Uint8List.fromList(ctData),
          key: SecureKeyFake(keyData),
        );

        verifyInOrder([
          () => mockSodium.crypto_ipcrypt_nd_decrypt(
            any(that: isNot(nullptr)),
            any(that: hasRawData<UnsignedChar>(ctData)),
            any(that: hasRawData<UnsignedChar>(keyData)),
          ),
        ]);
      });

      test('returns decrypt result', () {
        final ipData = List.generate(16, (i) => i + 20);

        when(
          () => mockSodium.crypto_ipcrypt_nd_decrypt(any(), any(), any()),
        ).thenAnswer((i) {
          fillPointer(
            i.positionalArguments[0] as Pointer<UnsignedChar>,
            ipData,
          );
        });

        final result = sut.decrypt(
          cipherText: Uint8List(24),
          key: SecureKeyFake.empty(5),
        );

        expect(result.bytes, ipData);

        // inPtr (finally) + key temp pointer = 2 frees
        verify(() => mockSodium.sodium_free(any())).called(2);
      });
    });
  });
}
