// ignore_for_file: unnecessary_lambdas

@TestOn('js')
library sodium_js_test;

import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/key_pair.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/js/api/crypto_js.dart';
import 'package:sodium/src/js/api/randombytes_js.dart';
import 'package:sodium/src/js/api/secure_key_js.dart';
import 'package:sodium/src/js/api/sodium_js.dart';
import 'package:sodium/src/js/bindings/js_error.dart';
import 'package:sodium/src/js/bindings/sodium.js.dart' hide KeyPair;
import 'package:test/test.dart';

class MockLibSodiumJS extends Mock implements LibSodiumJS {}

void main() {
  final mockSodium = MockLibSodiumJS();

  late SodiumJS sut;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    reset(mockSodium);

    sut = SodiumJS(mockSodium);
  });

  group('version', () {
    test('returns correct library version', () {
      const vStr = 'version';
      when(() => mockSodium.SODIUM_LIBRARY_VERSION_MAJOR).thenReturn(1);
      when(() => mockSodium.SODIUM_LIBRARY_VERSION_MINOR).thenReturn(2);
      when(() => mockSodium.sodium_version_string()).thenReturn(vStr);

      final version = sut.version;

      expect(version.major, 1);
      expect(version.minor, 2);
      expect(version.toString(), 'version');

      verify(() => mockSodium.SODIUM_LIBRARY_VERSION_MAJOR);
      verify(() => mockSodium.SODIUM_LIBRARY_VERSION_MINOR);
      verify(() => mockSodium.sodium_version_string());
    });

    test('throws SodiumException on JsError', () {
      when(() => mockSodium.SODIUM_LIBRARY_VERSION_MAJOR).thenReturn(1);
      when(() => mockSodium.SODIUM_LIBRARY_VERSION_MINOR).thenReturn(2);
      when(() => mockSodium.sodium_version_string()).thenThrow(JsError());

      expect(() => sut.version, throwsA(isA<SodiumException>()));
    });
  });

  group('pad', () {
    test('calls pad', () {
      final inBuf = Uint8List.fromList(const [1, 2, 3]);
      final outBuf = Uint8List.fromList(const [1, 2, 3, 4, 5]);
      const blocksize = 10;

      when(() => mockSodium.pad(any(), any())).thenReturn(outBuf);

      final res = sut.pad(inBuf, blocksize);

      expect(res, outBuf);
      verify(() => mockSodium.pad(inBuf, blocksize));
    });

    test('throws SodiumException on JsError', () {
      when(() => mockSodium.pad(any(), any())).thenThrow(JsError());

      expect(
        () => sut.pad(Uint8List(0), 10),
        throwsA(isA<SodiumException>()),
      );
    });
  });

  group('unpad', () {
    test('calls unpad', () {
      final inBuf = Uint8List.fromList(const [1, 2, 3, 4, 5]);
      final outBuf = Uint8List.fromList(const [1, 2, 3]);
      const blocksize = 10;

      when(() => mockSodium.unpad(any(), any())).thenReturn(outBuf);

      final res = sut.unpad(inBuf, blocksize);

      expect(res, outBuf);
      verify(() => mockSodium.unpad(inBuf, blocksize));
    });

    test('throws SodiumException on JsError', () {
      when(() => mockSodium.unpad(any(), any())).thenThrow(JsError());

      expect(
        () => sut.unpad(Uint8List(0), 10),
        throwsA(isA<SodiumException>()),
      );
    });
  });

  test('secureAlloc creates SecureKey instance', () {
    const length = 10;
    final res = sut.secureAlloc(length);

    expect(res.length, length);
  });

  test('secureRandom creates random SecureKey instance', () {
    const length = 10;
    when(() => mockSodium.randombytes_buf(any())).thenReturn(Uint8List(length));

    final res = sut.secureRandom(length);

    expect(res.length, length);

    verify(() => mockSodium.randombytes_buf(length));
  });

  test('secureCopy creates SecureKey instance with copied data', () {
    final data = Uint8List.fromList(List.generate(15, (index) => index));
    final res = sut.secureCopy(data);

    expect(res.extractBytes(), data);
  });

  test('randombytes returns RandombytesJS instance', () {
    expect(
      sut.randombytes,
      isA<RandombytesJS>().having(
        (p) => p.sodium,
        'sodium',
        mockSodium,
      ),
    );
  });

  test('crypto returns CryptoJS instance', () {
    expect(
      sut.crypto,
      isA<CryptoJS>().having(
        (p) => p.sodium,
        'sodium',
        mockSodium,
      ),
    );
  });

  test('runIsolated prints warning and runs callback synchronously', () async {
    final secureKey = SecureKeyJS(
      mockSodium,
      Uint8List.fromList(List.filled(10, 10)),
    );
    final keyPair = KeyPair(
      publicKey: Uint8List.fromList(List.filled(20, 20)),
      secretKey: SecureKeyJS(
        mockSodium,
        Uint8List.fromList(List.filled(30, 30)),
      ),
    );

    expect(
      () async {
        final result = await sut.runIsolated(
          secureKeys: [secureKey],
          keyPairs: [keyPair],
          (sodium, secureKeys, keyPairs) {
            expect(secureKeys, hasLength(1));
            expect(secureKeys.single, same(secureKey));
            expect(keyPairs, hasLength(1));
            expect(keyPairs.single, same(keyPair));
            return secureKeys.single;
          },
        );

        expect(result, same(secureKey));
      },
      prints(startsWith('WARNING: Sodium.runIsolated')),
    );
  });
}
