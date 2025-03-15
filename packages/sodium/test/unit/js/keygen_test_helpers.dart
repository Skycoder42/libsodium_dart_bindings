import 'dart:js_interop';
import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/key_pair.dart' as api;
import 'package:sodium/src/api/secure_key.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/js/bindings/js_error.dart';
import 'package:sodium/src/js/bindings/sodium.js.dart';
import 'package:test/test.dart';

import '../../secure_key_fake.dart';
import 'sodium_js_mock.dart';

@isTestGroup
void testKeygen({
  required MockLibSodiumJS mockSodium,
  required SecureKey Function() runKeygen,
  required JSUint8Array Function() keygenNative,
}) => group('keygen', () {
  test('calls native implementation on generated key', () {
    when(keygenNative).thenReturn(Uint8List(0).toJS);

    runKeygen();

    verify(keygenNative);
  });

  test('returns generated key', () {
    final testData = List.generate(11, (index) => index);
    when(keygenNative).thenReturn(Uint8List.fromList(testData).toJS);

    final res = runKeygen();

    expect(res.extractBytes(), testData);
  });

  test('throws SodiumException on JsError', () {
    when(keygenNative).thenThrow(JSError());

    expect(() => runKeygen(), throwsA(isA<SodiumException>()));
  });
});

@isTestGroup
void testKeypair({
  required MockLibSodiumJS mockSodium,
  required api.KeyPair Function() runKeypair,
  required KeyPair Function() keypairNative,
}) => group('keypair', () {
  test('calls native implementation to allocate keys', () {
    when(keypairNative).thenReturn(
      KeyPair(
        keyType: '',
        publicKey: Uint8List(0).toJS,
        privateKey: Uint8List(0).toJS,
      ),
    );

    runKeypair();

    verify(keypairNative);
  });

  test('returns generated key', () {
    final testPublic = List.generate(15, (index) => 15 - index);
    final testSecret = List.generate(5, (index) => index);
    when(keypairNative).thenReturn(
      KeyPair(
        keyType: '',
        publicKey: Uint8List.fromList(testPublic).toJS,
        privateKey: Uint8List.fromList(testSecret).toJS,
      ),
    );

    final res = runKeypair();

    expect(res.publicKey, testPublic);
    expect(res.secretKey.extractBytes(), testSecret);
  });

  test('disposes allocated key on error', () {
    when(keypairNative).thenThrow(JSError());

    expect(() => runKeypair(), throwsA(isA<Exception>()));
  });
});

@isTestGroup
void testSeedKeypair({
  required MockLibSodiumJS mockSodium,
  required api.KeyPair Function(SecureKey seed) runSeedKeypair,
  required int Function() seedBytesNative,
  required KeyPair Function(JSUint8Array seed) seedKeypairNative,
}) => group('seedKeypair', () {
  const seedLen = 33;

  setUp(() {
    when(seedBytesNative).thenReturn(seedLen);
  });

  test('asserts if seed is invalid', () {
    expect(
      () => runSeedKeypair(SecureKeyFake.empty(seedLen + 10)),
      throwsA(isA<RangeError>()),
    );

    verify(seedBytesNative);
  });

  test('calls crypto_box_seed_keypair on the keys with the seed', () {
    when(() => seedKeypairNative(any())).thenReturn(
      KeyPair(
        keyType: '',
        publicKey: Uint8List(0).toJS,
        privateKey: Uint8List(0).toJS,
      ),
    );

    final seed = List.generate(seedLen, (index) => 3 * index);
    runSeedKeypair(SecureKeyFake(seed));

    verify(() => seedKeypairNative(Uint8List.fromList(seed).toJS));
  });

  test('returns generated key', () {
    final testPublic = List.generate(15, (index) => 15 - index);
    final testSecret = List.generate(5, (index) => index);
    when(() => seedKeypairNative(any())).thenReturn(
      KeyPair(
        keyType: '',
        publicKey: Uint8List.fromList(testPublic).toJS,
        privateKey: Uint8List.fromList(testSecret).toJS,
      ),
    );

    final res = runSeedKeypair(SecureKeyFake.empty(seedLen));

    expect(res.publicKey, testPublic);
    expect(res.secretKey.extractBytes(), testSecret);
  });

  test('disposes allocated key on error', () {
    when(() => seedKeypairNative(any())).thenThrow(JSError());

    expect(
      () => runSeedKeypair(SecureKeyFake.empty(seedLen)),
      throwsA(isA<Exception>()),
    );
  });
});
