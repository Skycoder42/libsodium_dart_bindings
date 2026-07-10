@TestOn('js')
library;

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/js/api/ip_address_js.dart';
import 'package:sodium/src/js/api/ipcrypt_ndx_js.dart';
import 'package:sodium/src/js/bindings/js_error.dart';
import 'package:test/test.dart';

import '../../../secure_key_fake.dart';
import '../../../test_constants_mapping.dart';
import '../keygen_test_helpers.dart';
import '../sodium_js_mock.dart';

void main() {
  final mockSodium = MockLibSodiumJS();

  late IpcryptNdxJS sut;

  setUpAll(() {
    registerFallbackValue(Uint8List(0).toJS);
  });

  setUp(() {
    reset(mockSodium);
    sut = IpcryptNdxJS(mockSodium.asLibSodiumJS);
  });

  testConstantsMapping([
    (
      () => mockSodium.crypto_ipcrypt_NDX_KEYBYTES,
      () => sut.keyBytes,
      'keyBytes',
    ),
    (
      () => mockSodium.crypto_ipcrypt_NDX_TWEAKBYTES,
      () => sut.tweakBytes,
      'tweakBytes',
    ),
    (
      () => mockSodium.crypto_ipcrypt_NDX_INPUTBYTES,
      () => sut.inputBytes,
      'inputBytes',
    ),
    (
      () => mockSodium.crypto_ipcrypt_NDX_OUTPUTBYTES,
      () => sut.outputBytes,
      'outputBytes',
    ),
  ]);

  group('methods', () {
    setUp(() {
      when(() => mockSodium.crypto_ipcrypt_NDX_KEYBYTES).thenReturn(5);
      when(() => mockSodium.crypto_ipcrypt_NDX_TWEAKBYTES).thenReturn(5);
      when(() => mockSodium.crypto_ipcrypt_NDX_INPUTBYTES).thenReturn(16);
      when(() => mockSodium.crypto_ipcrypt_NDX_OUTPUTBYTES).thenReturn(32);
    });

    testKeygen(
      mockSodium: mockSodium,
      runKeygen: () => sut.keygen(),
      keygenNative: mockSodium.crypto_ipcrypt_ndx_keygen,
    );

    group('encrypt', () {
      test('asserts if input is invalid', () {
        when(() => mockSodium.crypto_ipcrypt_NDX_INPUTBYTES).thenReturn(17);

        final input = IpAddressJS.fromJsBytes(
          mockSodium.asLibSodiumJS,
          Uint8List(16).toJS,
        );

        expect(
          () => sut.encrypt(
            input: input,
            tweak: Uint8List(5),
            key: SecureKeyFake.empty(5),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_ipcrypt_NDX_INPUTBYTES);
      });

      test('asserts if tweak is invalid', () {
        final input = IpAddressJS.fromJsBytes(
          mockSodium.asLibSodiumJS,
          Uint8List(16).toJS,
        );

        expect(
          () => sut.encrypt(
            input: input,
            tweak: Uint8List(10),
            key: SecureKeyFake.empty(5),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_ipcrypt_NDX_TWEAKBYTES);
      });

      test('asserts if key is invalid', () {
        final input = IpAddressJS.fromJsBytes(
          mockSodium.asLibSodiumJS,
          Uint8List(16).toJS,
        );

        expect(
          () => sut.encrypt(
            input: input,
            tweak: Uint8List(5),
            key: SecureKeyFake.empty(10),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_ipcrypt_NDX_KEYBYTES);
      });

      test('calls crypto_ipcrypt_ndx_encrypt with correct arguments', () {
        when(
          () => mockSodium.crypto_ipcrypt_ndx_encrypt(any(), any(), any()),
        ).thenReturn(Uint8List(0).toJS);

        final ipData = List.generate(16, (i) => i);
        final ipJS = Uint8List.fromList(ipData).toJS;
        final input = IpAddressJS.fromJsBytes(mockSodium.asLibSodiumJS, ipJS);
        final tweakData = List.generate(5, (i) => i + 30);
        final keyData = List.generate(5, (i) => i + 50);

        sut.encrypt(
          input: input,
          tweak: Uint8List.fromList(tweakData),
          key: SecureKeyFake(keyData),
        );

        verify(
          () => mockSodium.crypto_ipcrypt_ndx_encrypt(
            ipJS,
            Uint8List.fromList(tweakData).toJS,
            Uint8List.fromList(keyData).toJS,
          ),
        );
      });

      test('returns encrypt result', () {
        final outData = List.generate(32, (i) => i + 10);

        when(
          () => mockSodium.crypto_ipcrypt_ndx_encrypt(any(), any(), any()),
        ).thenReturn(Uint8List.fromList(outData).toJS);

        final input = IpAddressJS.fromJsBytes(
          mockSodium.asLibSodiumJS,
          Uint8List(16).toJS,
        );

        final result = sut.encrypt(
          input: input,
          tweak: Uint8List(5),
          key: SecureKeyFake.empty(5),
        );

        expect(result, outData);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_ipcrypt_ndx_encrypt(any(), any(), any()),
        ).thenThrow(JSError());

        final input = IpAddressJS.fromJsBytes(
          mockSodium.asLibSodiumJS,
          Uint8List(16).toJS,
        );

        expect(
          () => sut.encrypt(
            input: input,
            tweak: Uint8List(5),
            key: SecureKeyFake.empty(5),
          ),
          throwsA(isA<SodiumException>()),
        );
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

        verify(() => mockSodium.crypto_ipcrypt_NDX_OUTPUTBYTES);
      });

      test('asserts if key is invalid', () {
        expect(
          () => sut.decrypt(
            cipherText: Uint8List(32),
            key: SecureKeyFake.empty(10),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_ipcrypt_NDX_KEYBYTES);
      });

      test('calls crypto_ipcrypt_ndx_decrypt with correct arguments', () {
        when(
          () => mockSodium.crypto_ipcrypt_ndx_decrypt(any(), any()),
        ).thenReturn(Uint8List(0).toJS);

        final ctData = List.generate(32, (i) => i + 5);
        final keyData = List.generate(5, (i) => i + 50);

        sut.decrypt(
          cipherText: Uint8List.fromList(ctData),
          key: SecureKeyFake(keyData),
        );

        verify(
          () => mockSodium.crypto_ipcrypt_ndx_decrypt(
            Uint8List.fromList(ctData).toJS,
            Uint8List.fromList(keyData).toJS,
          ),
        );
      });

      test('returns decrypt result', () {
        final ipData = List.generate(16, (i) => i + 20);

        when(
          () => mockSodium.crypto_ipcrypt_ndx_decrypt(any(), any()),
        ).thenReturn(Uint8List.fromList(ipData).toJS);

        final result = sut.decrypt(
          cipherText: Uint8List(32),
          key: SecureKeyFake.empty(5),
        );

        expect(result.bytes, ipData);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_ipcrypt_ndx_decrypt(any(), any()),
        ).thenThrow(JSError());

        expect(
          () => sut.decrypt(
            cipherText: Uint8List(32),
            key: SecureKeyFake.empty(5),
          ),
          throwsA(isA<SodiumException>()),
        );
      });
    });
  });
}
