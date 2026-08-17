// ignore_for_file: unnecessary_lambdas for mocking

@TestOn('js')
library;

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/key_pair.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/api/transferrable_secure_key.dart';
import 'package:sodium/src/js/api/crypto_js.dart';
import 'package:sodium/src/js/api/ip_address_js.dart';
import 'package:sodium/src/js/api/randombytes_js.dart';
import 'package:sodium/src/js/api/secure_key_js.dart';
import 'package:sodium/src/js/api/sodium_js.dart';
import 'package:sodium/src/js/api/transferrable_secure_key_js.dart';
import 'package:sodium/src/js/bindings/js_error.dart';
import 'package:test/test.dart';

import '../../../secure_key_fake.dart';
import '../../../test_data.dart';
import '../sodium_js_mock.dart';

class FakeTransferrableSecureKey extends Fake implements TransferrableSecureKey;

class FakeTransferrableKeyPair extends Fake implements TransferrableKeyPair;

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

      expect(() => sut.pad(Uint8List(0), 10), throwsA(isA<SodiumException>()));
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

  group('memcmp', () {
    final b1 = Uint8List.fromList(const [1, 2, 3, 4]);
    final b2 = Uint8List.fromList(const [5, 6, 7, 8]);

    setUp(() {
      when(() => mockSodium.memcmp(any(), any())).thenReturn(true);
    });

    test('asserts if b2 has a different length', () {
      expect(() => sut.memcmp(b1, Uint8List(3)), throwsA(isA<RangeError>()));

      verifyNever(() => mockSodium.memcmp(any(), any()));
    });

    test('calls memcmp with correct arguments', () {
      sut.memcmp(b1, b2);

      verify(() => mockSodium.memcmp(b1.toJS, b2.toJS));
    });

    test('returns true if memcmp returns true', () {
      final res = sut.memcmp(b1, b2);

      expect(res, isTrue);
    });

    test('returns false if memcmp returns false', () {
      when(() => mockSodium.memcmp(any(), any())).thenReturn(false);

      final res = sut.memcmp(b1, b2);

      expect(res, isFalse);
    });

    test('works with empty buffers', () {
      final res = sut.memcmp(Uint8List(0), Uint8List(0));

      expect(res, isTrue);
      verify(() => mockSodium.memcmp(Uint8List(0).toJS, Uint8List(0).toJS));
    });

    test('throws SodiumException on JSError', () {
      when(() => mockSodium.memcmp(any(), any())).thenThrow(JSError());

      expect(() => sut.memcmp(b1, b2), throwsA(isA<SodiumException>()));
    });
  });

  group('compare', () {
    final b1 = Uint8List.fromList(const [1, 2, 3, 4]);
    final b2 = Uint8List.fromList(const [5, 6, 7, 8]);

    setUp(() {
      when(() => mockSodium.compare(any(), any())).thenReturn(0);
    });

    test('asserts if b2 has a different length', () {
      expect(() => sut.compare(b1, Uint8List(3)), throwsA(isA<RangeError>()));

      verifyNever(() => mockSodium.compare(any(), any()));
    });

    test('calls compare with correct arguments', () {
      sut.compare(b1, b2);

      verify(() => mockSodium.compare(b1.toJS, b2.toJS));
    });

    testData<int>('returns the value reported by compare', const [-1, 0, 1], (
      fixture,
    ) {
      when(() => mockSodium.compare(any(), any())).thenReturn(fixture);

      final res = sut.compare(b1, b2);

      expect(res, fixture);
    });

    test('works with empty buffers', () {
      final res = sut.compare(Uint8List(0), Uint8List(0));

      expect(res, 0);
      verify(() => mockSodium.compare(Uint8List(0).toJS, Uint8List(0).toJS));
    });

    test('throws SodiumException on JSError', () {
      when(() => mockSodium.compare(any(), any())).thenThrow(JSError());

      expect(() => sut.compare(b1, b2), throwsA(isA<SodiumException>()));
    });
  });

  group('isZero', () {
    final testData = Uint8List.fromList(const [1, 2, 3, 4]);

    setUp(() {
      when(() => mockSodium.is_zero(any())).thenReturn(true);
    });

    test('calls is_zero with correct arguments', () {
      sut.isZero(testData);

      verify(() => mockSodium.is_zero(testData.toJS));
    });

    test('returns true if is_zero returns true', () {
      final res = sut.isZero(testData);

      expect(res, isTrue);
    });

    test('returns false if is_zero returns false', () {
      when(() => mockSodium.is_zero(any())).thenReturn(false);

      final res = sut.isZero(testData);

      expect(res, isFalse);
    });

    test('works with an empty buffer', () {
      final res = sut.isZero(Uint8List(0));

      expect(res, isTrue);
      verify(() => mockSodium.is_zero(Uint8List(0).toJS));
    });

    test('throws SodiumException on JSError', () {
      when(() => mockSodium.is_zero(any())).thenThrow(JSError());

      expect(() => sut.isZero(testData), throwsA(isA<SodiumException>()));
    });
  });

  group('increment', () {
    setUp(() {
      when(() => mockSodium.increment(any())).thenAnswer((_) {});
    });

    test('calls increment on a copy of the input', () {
      final input = Uint8List.fromList(const [1, 2, 3, 4]);

      sut.increment(input);

      final captured = verify(() => mockSodium.increment(captureAny()))
          .captured;
      expect(captured, hasLength(1));

      final jsArg = captured.single as JSUint8Array;
      expect(jsArg.toDart, input);
      expect(jsArg.toDart, isNot(same(input)));
    });

    test('returns the incremented buffer without mutating the input', () {
      const incremented = [2, 2, 3, 4];
      when(() => mockSodium.increment(any())).thenAnswer((i) {
        (i.positionalArguments.first as JSUint8Array).toDart.setAll(
          0,
          incremented,
        );
      });

      final input = Uint8List.fromList(const [1, 2, 3, 4]);
      final res = sut.increment(input);

      expect(res, incremented);
      expect(input, const [1, 2, 3, 4]);
      expect(res, isNot(same(input)));
    });

    test('works with an empty buffer', () {
      final res = sut.increment(Uint8List(0));

      expect(res, isEmpty);
      verify(() => mockSodium.increment(Uint8List(0).toJS));
    });

    test('throws SodiumException on JSError', () {
      when(() => mockSodium.increment(any())).thenThrow(JSError());

      expect(
        () => sut.increment(Uint8List(4)),
        throwsA(isA<SodiumException>()),
      );
    });
  });

  group('add', () {
    final a = Uint8List.fromList(const [1, 2, 3, 4]);
    final b = Uint8List.fromList(const [5, 6, 7, 8]);

    setUp(() {
      when(() => mockSodium.add(any(), any())).thenAnswer((_) {});
    });

    test('asserts if b has a different length', () {
      expect(() => sut.add(a, Uint8List(3)), throwsA(isA<RangeError>()));

      verifyNever(() => mockSodium.add(any(), any()));
    });

    test('calls add on a copy of a with b as second operand', () {
      final aInput = Uint8List.fromList(const [1, 2, 3, 4]);

      sut.add(aInput, b);

      final captured = verify(() => mockSodium.add(captureAny(), captureAny()))
          .captured;
      expect(captured, hasLength(2));

      final jsA = captured[0] as JSUint8Array;
      expect(jsA.toDart, aInput);
      expect(jsA.toDart, isNot(same(aInput)));
      expect((captured[1] as JSUint8Array).toDart, b);
    });

    test('returns the sum without mutating the inputs', () {
      const sum = [6, 8, 10, 12];
      when(() => mockSodium.add(any(), any())).thenAnswer((i) {
        (i.positionalArguments.first as JSUint8Array).toDart.setAll(0, sum);
      });

      final aInput = Uint8List.fromList(const [1, 2, 3, 4]);
      final bInput = Uint8List.fromList(const [5, 6, 7, 8]);
      final res = sut.add(aInput, bInput);

      expect(res, sum);
      expect(aInput, const [1, 2, 3, 4]);
      expect(bInput, const [5, 6, 7, 8]);
      expect(res, isNot(same(aInput)));
    });

    test('works with empty buffers', () {
      final res = sut.add(Uint8List(0), Uint8List(0));

      expect(res, isEmpty);
      verify(() => mockSodium.add(Uint8List(0).toJS, Uint8List(0).toJS));
    });

    test('throws SodiumException on JSError', () {
      when(() => mockSodium.add(any(), any())).thenThrow(JSError());

      expect(() => sut.add(a, b), throwsA(isA<SodiumException>()));
    });
  });

  group('sub', () {
    // libsodium.js has no `sub` binding - the implementation is pure dart, so
    // it is tested behaviorally instead of via mock verifications.
    final a = Uint8List.fromList(const [5, 6, 7, 8]);
    final b = Uint8List.fromList(const [1, 2, 3, 4]);

    test('asserts if b has a different length', () {
      expect(() => sut.sub(a, Uint8List(3)), throwsA(isA<RangeError>()));
    });

    const testCases = <(String, List<int>, List<int>, List<int>)>[
      ('simple subtraction', [5, 6, 7, 8], [1, 2, 3, 4], [4, 4, 4, 4]),
      ('subtraction of zero', [1, 2], [0, 0], [1, 2]),
      ('subtraction of itself', [9, 9], [9, 9], [0, 0]),
      ('single borrow', [0, 1, 0, 0], [1, 0, 0, 0], [255, 0, 0, 0]),
      ('chained borrow', [0, 0, 1], [1, 0, 0], [255, 255, 0]),
      ('wrap around below zero', [0, 0], [1, 0], [255, 255]),
      ('little endian byte order', [0x00, 0x01], [0x01, 0x00], [0xFF, 0x00]),
    ];

    testData<(String, List<int>, List<int>, List<int>)>(
      'computes the difference',
      testCases,
      (fixture) {
        final res = sut.sub(
          Uint8List.fromList(fixture.$2),
          Uint8List.fromList(fixture.$3),
        );

        expect(res, fixture.$4);
      },
      fixtureToString: (fixture) => fixture.$1,
    );

    test('returns a new buffer without mutating the inputs', () {
      final aInput = Uint8List.fromList(const [5, 6, 7, 8]);
      final bInput = Uint8List.fromList(const [1, 2, 3, 4]);

      final res = sut.sub(aInput, bInput);

      expect(res, const [4, 4, 4, 4]);
      expect(aInput, const [5, 6, 7, 8]);
      expect(bInput, const [1, 2, 3, 4]);
      expect(res, isNot(same(aInput)));
      expect(res, isNot(same(bInput)));
    });

    test('works with empty buffers', () {
      final res = sut.sub(Uint8List(0), Uint8List(0));

      expect(res, isEmpty);
    });

    test('does not call into libsodium.js at all', () {
      sut.sub(a, b);

      verifyZeroInteractions(mockSodium);
    });
  });

  group('bin2hex', () {
    final testData = Uint8List.fromList(const [0x01, 0xab, 0xff]);
    const hex = '01abff';

    setUp(() {
      when(() => mockSodium.to_hex(any())).thenReturn(hex);
    });

    test('calls to_hex with correct arguments', () {
      sut.bin2hex(testData);

      verify(() => mockSodium.to_hex(testData.toJS));
    });

    test('returns the hex string as reported by to_hex', () {
      final res = sut.bin2hex(testData);

      expect(res, hex);
    });

    test('returns an empty string for an empty input', () {
      when(() => mockSodium.to_hex(any())).thenReturn('');

      final res = sut.bin2hex(Uint8List(0));

      expect(res, isEmpty);
      verify(() => mockSodium.to_hex(Uint8List(0).toJS));
    });

    test('throws SodiumException on JSError', () {
      when(() => mockSodium.to_hex(any())).thenThrow(JSError());

      expect(() => sut.bin2hex(testData), throwsA(isA<SodiumException>()));
    });
  });

  group('hex2bin', () {
    const hex = '0a1b2c';
    const binData = [0x0a, 0x1b, 0x2c];

    setUp(() {
      when(() => mockSodium.from_hex(any()))
          .thenReturn(Uint8List.fromList(binData).toJS);
    });

    test('throws if hex is not ascii', () {
      expect(() => sut.hex2bin('0ä1b'), throwsA(isA<ArgumentError>()));

      verifyNever(() => mockSodium.from_hex(any()));
    });

    test('calls from_hex with correct arguments', () {
      sut.hex2bin(hex);

      verify(() => mockSodium.from_hex(hex));
    });

    test('returns the bin data as reported by from_hex', () {
      final res = sut.hex2bin(hex);

      expect(res, binData);
    });

    test('returns an empty list for an empty hex string', () {
      when(() => mockSodium.from_hex(any())).thenReturn(Uint8List(0).toJS);

      final res = sut.hex2bin('');

      expect(res, isEmpty);
      verify(() => mockSodium.from_hex(''));
    });

    test('throws SodiumException on JSError', () {
      when(() => mockSodium.from_hex(any())).thenThrow(JSError());

      expect(() => sut.hex2bin(hex), throwsA(isA<SodiumException>()));
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
      isA<RandombytesJS>().having((p) => p.sodium, 'sodium', sut.sodium),
    );
  });

  test('crypto returns CryptoJS instance', () {
    expect(
      sut.crypto,
      isA<CryptoJS>().having((p) => p.sodium, 'sodium', sut.sodium),
    );
  });

  group('ipFromAddress', () {
    test('returns IpAddressJS by converting the address string', () {
      final ipData = List.generate(16, (i) => i + 1);
      when(() => mockSodium.sodium_ip2bin(any()))
          .thenReturn(Uint8List.fromList(ipData).toJS);

      final result = sut.ipFromAddress('192.168.0.1');

      expect(result, isA<IpAddressJS>());
      expect(result.bytes, ipData);
      verify(() => mockSodium.sodium_ip2bin('192.168.0.1'));
    });
  });

  group('ipFromString', () {
    test('returns IpAddressJS by converting the address string', () {
      final ipData = List.generate(16, (i) => i + 1);
      when(() => mockSodium.sodium_ip2bin(any()))
          .thenReturn(Uint8List.fromList(ipData).toJS);

      final result = sut.ipFromString('::1');

      expect(result, isA<IpAddressJS>());
      expect(result.bytes, ipData);
      verify(() => mockSodium.sodium_ip2bin('::1'));
    });
  });

  group('ipFromBytes', () {
    test('returns IpAddressJS with the given bytes', () {
      final bytes = Uint8List.fromList(List.generate(16, (i) => i));
      final result = sut.ipFromBytes(bytes);

      expect(result, isA<IpAddressJS>());
      expect(result.bytes, bytes);
    });
  });

  group('runIsolated', () {
    test('prints warning and runs callback synchronously', () {
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

      expect(() async {
        final result = await sut.runIsolated(
          secureKeys: [secureKey],
          keyPairs: [keyPair],
          (secureKeys, keyPairs) {
            expect(secureKeys, hasLength(1));
            expect(secureKeys.single, same(secureKey));
            expect(keyPairs, hasLength(1));
            expect(keyPairs.single, same(keyPair));
            return secureKeys.single;
          },
        );

        expect(result, same(secureKey));
      }, prints(startsWith('WARNING: Sodium.runIsolated')));
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
          () => sut.materializeTransferrableSecureKey(
            FakeTransferrableSecureKey(),
          ),
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
