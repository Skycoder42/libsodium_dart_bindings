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

@isTestGroup
void testKeygen({
  required LibSodiumJS mockSodium,
  required SecureKey Function() runKeygen,
  required Uint8List Function() keygenNative,
}) =>
    group('keygen', () {
      assert(mockSodium is Mock);

      test('calls native implementation on generated key', () {
        when(keygenNative).thenReturn(Uint8List(0));

        runKeygen();

        verify(keygenNative);
      });

      test('returns generated key', () {
        final testData = List.generate(11, (index) => index);
        when(keygenNative).thenReturn(Uint8List.fromList(testData));

        final res = runKeygen();

        expect(res.extractBytes(), testData);
      });

      test('throws SodiumException on JsError', () {
        when(keygenNative).thenThrow(JsError());

        expect(() => runKeygen(), throwsA(isA<SodiumException>()));
      });
    });

@isTestGroup
void testKeypair({
  required LibSodiumJS mockSodium,
  required api.KeyPair Function() runKeypair,
  required KeyPair Function() keypairNative,
}) =>
    group('keypair', () {
      assert(mockSodium is Mock);

      test('calls native implementation to allocate keys', () {
        when(keypairNative).thenReturn(KeyPair(
          keyType: '',
          publicKey: Uint8List(0),
          privateKey: Uint8List(0),
        ));

        runKeypair();

        verify(keypairNative);
      });

      test('returns generated key', () {
        final testPublic = List.generate(15, (index) => 15 - index);
        final testSecret = List.generate(5, (index) => index);
        when(keypairNative).thenReturn(KeyPair(
          keyType: '',
          publicKey: Uint8List.fromList(testPublic),
          privateKey: Uint8List.fromList(testSecret),
        ));

        final res = runKeypair();

        expect(res.publicKey, testPublic);
        expect(res.secretKey.extractBytes(), testSecret);
      });

      test('disposes allocated key on error', () {
        when(keypairNative).thenThrow(JsError());

        expect(() => runKeypair(), throwsA(isA<Exception>()));
      });
    });

@isTestGroup
void testSeedKeypair({
  required LibSodiumJS mockSodium,
  required api.KeyPair Function(SecureKey seed) runSeedKeypair,
  required num Function() seedBytesNative,
  required KeyPair Function(Uint8List seed) seedKeypairNative,
}) =>
    group('seedKeypair', () {
      const seedLen = 33;

      assert(mockSodium is Mock);

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
        when(() => seedKeypairNative(any())).thenReturn(KeyPair(
          keyType: '',
          publicKey: Uint8List(0),
          privateKey: Uint8List(0),
        ));

        final seed = List.generate(seedLen, (index) => 3 * index);
        runSeedKeypair(SecureKeyFake(seed));

        verify(
          () => seedKeypairNative(Uint8List.fromList(seed)),
        );
      });

      test('returns generated key', () {
        final testPublic = List.generate(15, (index) => 15 - index);
        final testSecret = List.generate(5, (index) => index);
        when(() => seedKeypairNative(any())).thenReturn(KeyPair(
          keyType: '',
          publicKey: Uint8List.fromList(testPublic),
          privateKey: Uint8List.fromList(testSecret),
        ));

        final res = runSeedKeypair(SecureKeyFake.empty(seedLen));

        expect(res.publicKey, testPublic);
        expect(res.secretKey.extractBytes(), testSecret);
      });

      test('disposes allocated key on error', () {
        when(() => seedKeypairNative(any())).thenThrow(JsError());

        expect(
          () => runSeedKeypair(SecureKeyFake.empty(seedLen)),
          throwsA(isA<Exception>()),
        );
      });
    });
