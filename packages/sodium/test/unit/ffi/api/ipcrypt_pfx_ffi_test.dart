// ignore_for_file: unnecessary_lambdas to catch member access errors

@TestOn('dart-vm')
library;

import 'dart:ffi';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/ffi/api/ip_address_ffi.dart';
import 'package:sodium/src/ffi/api/ipcrypt_pfx_ffi.dart';
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

  late IpcryptPfxFFI sut;

  setUpAll(() {
    registerPointers();
  });

  setUp(() {
    reset(mockSodium);
    mockAllocArray(mockSodium);
    sut = IpcryptPfxFFI(mockSodium);
  });

  testConstantsMapping([
    (
      () => mockSodium.crypto_ipcrypt_pfx_keybytes(),
      () => sut.keyBytes,
      'keyBytes',
    ),
    (() => mockSodium.crypto_ipcrypt_pfx_bytes(), () => sut.bytes, 'bytes'),
  ]);

  group('methods', () {
    setUp(() {
      when(() => mockSodium.crypto_ipcrypt_pfx_keybytes()).thenReturn(5);
      when(() => mockSodium.crypto_ipcrypt_pfx_bytes()).thenReturn(16);
    });

    testKeygen(
      mockSodium: mockSodium,
      runKeygen: () => sut.keygen(),
      keyBytesNative: mockSodium.crypto_ipcrypt_pfx_keybytes,
      keygenNative: mockSodium.crypto_ipcrypt_pfx_keygen,
    );

    group('encrypt', () {
      test('asserts if input is invalid', () {
        when(() => mockSodium.crypto_ipcrypt_pfx_bytes()).thenReturn(17);

        final ptr = SodiumPointer<UnsignedChar>.alloc(mockSodium, count: 16);
        final input = IpAddressFFI.fromPointer(mockSodium, ptr);

        expect(
          () => sut.encrypt(input: input, key: SecureKeyFake.empty(5)),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_ipcrypt_pfx_bytes());
      });

      test('asserts if key is invalid', () {
        final ptr = SodiumPointer<UnsignedChar>.alloc(mockSodium, count: 16);
        final input = IpAddressFFI.fromPointer(mockSodium, ptr);

        expect(
          () => sut.encrypt(input: input, key: SecureKeyFake.empty(10)),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_ipcrypt_pfx_keybytes());
      });

      test('calls crypto_ipcrypt_pfx_encrypt with correct arguments', () {
        when(
          () => mockSodium.crypto_ipcrypt_pfx_encrypt(any(), any(), any()),
        ).thenAnswer((_) {});

        final ipData = List.generate(16, (i) => i);
        final ptr = SodiumPointer<UnsignedChar>.alloc(mockSodium, count: 16);
        fillPointer(ptr.ptr, ipData);
        final input = IpAddressFFI.fromPointer(mockSodium, ptr);
        final keyData = List.generate(5, (i) => i + 50);

        sut.encrypt(input: input, key: SecureKeyFake(keyData));

        verifyInOrder([
          () => mockSodium.crypto_ipcrypt_pfx_encrypt(
            any(that: isNot(nullptr)),
            any(that: hasRawData<UnsignedChar>(ipData)),
            any(that: hasRawData<UnsignedChar>(keyData)),
          ),
        ]);
      });

      test('returns encrypt result', () {
        final outData = List.generate(16, (i) => i + 10);

        when(
          () => mockSodium.crypto_ipcrypt_pfx_encrypt(any(), any(), any()),
        ).thenAnswer((i) {
          fillPointer(
            i.positionalArguments[0] as Pointer<UnsignedChar>,
            outData,
          );
        });

        final ptr = SodiumPointer<UnsignedChar>.alloc(mockSodium, count: 16);
        final input = IpAddressFFI.fromPointer(mockSodium, ptr);

        final result = sut.encrypt(input: input, key: SecureKeyFake.empty(5));

        expect(result, outData);

        // Only key temp pointer freed (outPtr transferred via asListView)
        verify(() => mockSodium.sodium_free(any())).called(1);
      });
    });

    group('decrypt', () {
      test('asserts if input is invalid', () {
        expect(
          () => sut.decrypt(input: Uint8List(10), key: SecureKeyFake.empty(5)),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_ipcrypt_pfx_bytes());
      });

      test('asserts if key is invalid', () {
        expect(
          () => sut.decrypt(input: Uint8List(16), key: SecureKeyFake.empty(10)),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_ipcrypt_pfx_keybytes());
      });

      test('calls crypto_ipcrypt_pfx_decrypt with correct arguments', () {
        when(
          () => mockSodium.crypto_ipcrypt_pfx_decrypt(any(), any(), any()),
        ).thenAnswer((_) {});

        final inputData = List.generate(16, (i) => i + 5);
        final keyData = List.generate(5, (i) => i + 50);

        sut.decrypt(
          input: Uint8List.fromList(inputData),
          key: SecureKeyFake(keyData),
        );

        verifyInOrder([
          () => mockSodium.crypto_ipcrypt_pfx_decrypt(
            any(that: isNot(nullptr)),
            any(that: hasRawData<UnsignedChar>(inputData)),
            any(that: hasRawData<UnsignedChar>(keyData)),
          ),
        ]);
      });

      test('returns decrypt result', () {
        final ipData = List.generate(16, (i) => i + 20);

        when(
          () => mockSodium.crypto_ipcrypt_pfx_decrypt(any(), any(), any()),
        ).thenAnswer((i) {
          fillPointer(
            i.positionalArguments[0] as Pointer<UnsignedChar>,
            ipData,
          );
        });

        final result = sut.decrypt(
          input: Uint8List(16),
          key: SecureKeyFake.empty(5),
        );

        expect(result.bytes, ipData);

        // inPtr (finally) + key temp pointer = 2 frees
        verify(() => mockSodium.sodium_free(any())).called(2);
      });
    });
  });
}
