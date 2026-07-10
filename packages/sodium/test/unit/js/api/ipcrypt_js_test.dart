@TestOn('js')
library;

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/js/api/ip_address_js.dart';
import 'package:sodium/src/js/api/ipcrypt_js.dart';
import 'package:sodium/src/js/api/ipcrypt_nd_js.dart';
import 'package:sodium/src/js/api/ipcrypt_ndx_js.dart';
import 'package:sodium/src/js/api/ipcrypt_pfx_js.dart';
import 'package:sodium/src/js/bindings/js_error.dart';
import 'package:test/test.dart';

import '../../../secure_key_fake.dart';
import '../../../test_constants_mapping.dart';
import '../keygen_test_helpers.dart';
import '../sodium_js_mock.dart';

void main() {
  final mockSodium = MockLibSodiumJS();

  late IpcryptJS sut;

  setUpAll(() {
    registerFallbackValue(Uint8List(0).toJS);
  });

  setUp(() {
    reset(mockSodium);
    sut = IpcryptJS(mockSodium.asLibSodiumJS);
  });

  testConstantsMapping([
    (() => mockSodium.crypto_ipcrypt_BYTES, () => sut.bytes, 'bytes'),
    (() => mockSodium.crypto_ipcrypt_KEYBYTES, () => sut.keyBytes, 'keyBytes'),
  ]);

  group('nd', () {
    test('returns IpcryptNdJS instance', () {
      expect(sut.nd, isA<IpcryptNdJS>());
    });
  });

  group('ndx', () {
    test('returns IpcryptNdxJS instance', () {
      expect(sut.ndx, isA<IpcryptNdxJS>());
    });
  });

  group('pfx', () {
    test('returns IpcryptPfxJS instance', () {
      expect(sut.pfx, isA<IpcryptPfxJS>());
    });
  });

  group('methods', () {
    setUp(() {
      when(() => mockSodium.crypto_ipcrypt_BYTES).thenReturn(16);
      when(() => mockSodium.crypto_ipcrypt_KEYBYTES).thenReturn(5);
    });

    testKeygen(
      mockSodium: mockSodium,
      runKeygen: () => sut.keygen(),
      keygenNative: mockSodium.crypto_ipcrypt_keygen,
    );

    group('encrypt', () {
      test('asserts if input is invalid', () {
        when(() => mockSodium.crypto_ipcrypt_BYTES).thenReturn(17);

        final input = IpAddressJS.fromJsBytes(
          mockSodium.asLibSodiumJS,
          Uint8List(16).toJS,
        );

        expect(
          () => sut.encrypt(input: input, key: SecureKeyFake.empty(5)),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_ipcrypt_BYTES);
      });

      test('asserts if key is invalid', () {
        final input = IpAddressJS.fromJsBytes(
          mockSodium.asLibSodiumJS,
          Uint8List(16).toJS,
        );

        expect(
          () => sut.encrypt(input: input, key: SecureKeyFake.empty(10)),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_ipcrypt_KEYBYTES);
      });

      test('calls crypto_ipcrypt_encrypt with correct arguments', () {
        when(
          () => mockSodium.crypto_ipcrypt_encrypt(any(), any()),
        ).thenReturn(Uint8List(0).toJS);

        final ipData = List.generate(16, (i) => i);
        final ipJS = Uint8List.fromList(ipData).toJS;
        final input = IpAddressJS.fromJsBytes(mockSodium.asLibSodiumJS, ipJS);
        final keyData = List.generate(5, (i) => i + 50);

        sut.encrypt(input: input, key: SecureKeyFake(keyData));

        verify(
          () => mockSodium.crypto_ipcrypt_encrypt(
            ipJS,
            Uint8List.fromList(keyData).toJS,
          ),
        );
      });

      test('returns encrypt result', () {
        final outData = List.generate(16, (i) => i + 10);

        when(
          () => mockSodium.crypto_ipcrypt_encrypt(any(), any()),
        ).thenReturn(Uint8List.fromList(outData).toJS);

        final input = IpAddressJS.fromJsBytes(
          mockSodium.asLibSodiumJS,
          Uint8List(16).toJS,
        );

        final result = sut.encrypt(input: input, key: SecureKeyFake.empty(5));

        expect(result, outData);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_ipcrypt_encrypt(any(), any()),
        ).thenThrow(JSError());

        final input = IpAddressJS.fromJsBytes(
          mockSodium.asLibSodiumJS,
          Uint8List(16).toJS,
        );

        expect(
          () => sut.encrypt(input: input, key: SecureKeyFake.empty(5)),
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

        verify(() => mockSodium.crypto_ipcrypt_BYTES);
      });

      test('asserts if key is invalid', () {
        expect(
          () => sut.decrypt(
            cipherText: Uint8List(16),
            key: SecureKeyFake.empty(10),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_ipcrypt_KEYBYTES);
      });

      test('calls crypto_ipcrypt_decrypt with correct arguments', () {
        when(
          () => mockSodium.crypto_ipcrypt_decrypt(any(), any()),
        ).thenReturn(Uint8List(0).toJS);

        final inputData = List.generate(16, (i) => i + 5);
        final keyData = List.generate(5, (i) => i + 50);

        sut.decrypt(
          cipherText: Uint8List.fromList(inputData),
          key: SecureKeyFake(keyData),
        );

        verify(
          () => mockSodium.crypto_ipcrypt_decrypt(
            Uint8List.fromList(inputData).toJS,
            Uint8List.fromList(keyData).toJS,
          ),
        );
      });

      test('returns decrypt result', () {
        final ipData = List.generate(16, (i) => i + 20);

        when(
          () => mockSodium.crypto_ipcrypt_decrypt(any(), any()),
        ).thenReturn(Uint8List.fromList(ipData).toJS);

        final result = sut.decrypt(
          cipherText: Uint8List(16),
          key: SecureKeyFake.empty(5),
        );

        expect(result.bytes, ipData);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_ipcrypt_decrypt(any(), any()),
        ).thenThrow(JSError());

        expect(
          () => sut.decrypt(
            cipherText: Uint8List(16),
            key: SecureKeyFake.empty(5),
          ),
          throwsA(isA<SodiumException>()),
        );
      });
    });
  });
}
