// ignore_for_file: unnecessary_lambdas

@TestOn('js')
library;

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/key_pair.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/api/transferrable_secure_key.dart';
import 'package:sodium/src/js/api/crypto_js.dart';
import 'package:sodium/src/js/api/randombytes_js.dart';
import 'package:sodium/src/js/api/secure_key_js.dart';
import 'package:sodium/src/js/api/sodium_js.dart';
import 'package:sodium/src/js/api/transferrable_secure_key_js.dart';
import 'package:sodium/src/js/bindings/js_error.dart';
import 'package:test/test.dart';

import '../../../secure_key_fake.dart';
import '../sodium_js_mock.dart';

class FakeTransferrableSecureKey extends Fake
    implements TransferrableSecureKey {}

class FakeTransferrableKeyPair extends Fake implements TransferrableKeyPair {}

void main() {
  final mockSodium = MockLibSodiumJS();

  late SodiumJS sut;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    reset(mockSodium);

    sut = SodiumJS(mockSodium.asLibSodiumJS);
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

    test('throws SodiumException on JSError', () {
      when(() => mockSodium.SODIUM_LIBRARY_VERSION_MAJOR).thenReturn(1);
      when(() => mockSodium.SODIUM_LIBRARY_VERSION_MINOR).thenReturn(2);
      when(() => mockSodium.sodium_version_string()).thenThrow(JSError());

      expect(() => sut.version, throwsA(isA<SodiumException>()));
    });
  });

  group('pad', () {
    test('calls pad', () {
      final inBuf = Uint8List.fromList(const [1, 2, 3]);
      final outBuf = Uint8List.fromList(const [1, 2, 3, 4, 5]);
      const blocksize = 10;

      when(() => mockSodium.pad(any(), any())).thenReturn(outBuf.toJS);

      final res = sut.pad(inBuf, blocksize);

      expect(res, outBuf);
      verify(() => mockSodium.pad(inBuf.toJS, blocksize));
    });

    test('throws SodiumException on JSError', () {
      when(() => mockSodium.pad(any(), any())).thenThrow(JSError());

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

      when(() => mockSodium.unpad(any(), any())).thenReturn(outBuf.toJS);

      final res = sut.unpad(inBuf, blocksize);

      expect(res, outBuf);
      verify(() => mockSodium.unpad(inBuf.toJS, blocksize));
    });

    test('throws SodiumException on JSError', () {
      when(() => mockSodium.unpad(any(), any())).thenThrow(JSError());

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
    when(() => mockSodium.randombytes_buf(any()))
        .thenReturn(Uint8List(length).toJS);

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
        sut.sodium,
      ),
    );
  });

  test('crypto returns CryptoJS instance', () {
    expect(
      sut.crypto,
      isA<CryptoJS>().having(
        (p) => p.sodium,
        'sodium',
        sut.sodium,
      ),
    );
  });

  group('runIsolated', () {
    test('invokes the given callback with a sodium instance', () async {
      final isSodium = await sut.runIsolated(
        (sodium, secureKeys, keyPairs) => sodium is SodiumJS,
      );

      expect(isSodium, isTrue);
    });

    test('prints warning and runs callback synchronously', () async {
      final secureKey = SecureKeyJS(
        mockSodium.asLibSodiumJS,
        Uint8List.fromList(List.filled(10, 10)).toJS,
      );
      final keyPair = KeyPair(
        publicKey: Uint8List.fromList(List.filled(20, 20)),
        secretKey: SecureKeyJS(
          mockSodium.asLibSodiumJS,
          Uint8List.fromList(List.filled(30, 30)).toJS,
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

    test('isolateFactory creates factory that returns this', () async {
      expect(sut.isolateFactory(), completion(same(sut)));
    });

    test('createTransferrableSecureKey returns wrapped secure key', () {
      final key = SecureKeyFake.empty(10);
      final transferrableKey = sut.createTransferrableSecureKey(key);

      expect(transferrableKey, isA<TransferrableSecureKeyJS>());
      final jsKey = transferrableKey as TransferrableSecureKeyJS;

      expect(jsKey.secureKey, same(key));
    });

    group('materializeTransferrableSecureKey', () {
      test('unwraps transferrable key', () {
        final key = SecureKeyFake.empty(10);
        final transferrableKey = TransferrableSecureKeyJS(key);

        final restored = sut.materializeTransferrableSecureKey(
          transferrableKey,
        );

        expect(restored, same(key));
      });

      test('throws exception if not a JS key', () {
        expect(
          () => sut
              .materializeTransferrableSecureKey(FakeTransferrableSecureKey()),
          throwsA(
            isA<SodiumException>().having(
              (m) => m.originalMessage,
              'originalMessage',
              contains('$FakeTransferrableSecureKey'),
            ),
          ),
        );
      });
    });

    test('createTransferrableKeyPair returns wrapped key pair', () {
      final keyPair = KeyPair(
        publicKey: Uint8List(5),
        secretKey: SecureKeyFake.empty(10),
      );
      final transferrableKeyPair = sut.createTransferrableKeyPair(keyPair);

      expect(transferrableKeyPair, isA<TransferrableKeyPairJS>());
      final jsKey = transferrableKeyPair as TransferrableKeyPairJS;

      expect(jsKey.keyPair, same(keyPair));
    });

    group('materializeTransferrableKeyPair', () {
      test('unwraps transferrable key pair', () {
        final keyPair = KeyPair(
          publicKey: Uint8List(5),
          secretKey: SecureKeyFake.empty(10),
        );
        final transferrableKeyPair = TransferrableKeyPairJS(keyPair);

        final restored = sut.materializeTransferrableKeyPair(
          transferrableKeyPair,
        );

        expect(restored, same(keyPair));
      });

      test('throws exception if not a JS key', () {
        expect(
          () => sut.materializeTransferrableKeyPair(FakeTransferrableKeyPair()),
          throwsA(
            isA<SodiumException>().having(
              (m) => m.originalMessage,
              'originalMessage',
              contains('$FakeTransferrableKeyPair'),
            ),
          ),
        );
      });
    });
  });
}
