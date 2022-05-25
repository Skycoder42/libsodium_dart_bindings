@TestOn('js')

import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/secure_key.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/js/api/kx_js.dart';
import 'package:sodium/src/js/bindings/js_error.dart';
import 'package:sodium/src/js/bindings/sodium.js.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

import '../../../secure_key_fake.dart';
import '../../../test_constants_mapping.dart';
import '../keygen_test_helpers.dart';

class MockLibSodiumJS extends Mock implements LibSodiumJS {}

void main() {
  final mockSodium = MockLibSodiumJS();

  late KxJS sut;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    reset(mockSodium);

    sut = KxJS(mockSodium);
  });

  testConstantsMapping([
    Tuple3(
      () => mockSodium.crypto_kx_PUBLICKEYBYTES,
      () => sut.publicKeyBytes,
      'publicKeyBytes',
    ),
    Tuple3(
      () => mockSodium.crypto_kx_SECRETKEYBYTES,
      () => sut.secretKeyBytes,
      'secretKeyBytes',
    ),
    Tuple3(
      () => mockSodium.crypto_kx_SEEDBYTES,
      () => sut.seedBytes,
      'seedBytes',
    ),
    Tuple3(
      () => mockSodium.crypto_kx_SESSIONKEYBYTES,
      () => sut.sessionKeyBytes,
      'sessionKeyBytes',
    ),
  ]);

  group('methods', () {
    setUp(() {
      when(() => mockSodium.crypto_kx_PUBLICKEYBYTES).thenReturn(5);
      when(() => mockSodium.crypto_kx_SECRETKEYBYTES).thenReturn(5);
      when(() => mockSodium.crypto_kx_SEEDBYTES).thenReturn(5);
      when(() => mockSodium.crypto_kx_SESSIONKEYBYTES).thenReturn(10);
    });

    testKeypair(
      mockSodium: mockSodium,
      runKeypair: () => sut.keyPair(),
      keypairNative: mockSodium.crypto_kx_keypair,
    );

    testSeedKeypair(
      mockSodium: mockSodium,
      runSeedKeypair: (SecureKey seed) => sut.seedKeyPair(seed),
      seedBytesNative: () => mockSodium.crypto_kx_SEEDBYTES,
      seedKeypairNative: mockSodium.crypto_kx_seed_keypair,
    );

    group('clientSessionKeys', () {
      test('asserts if clientPublicKey is invalid', () {
        expect(
          () => sut.clientSessionKeys(
            clientPublicKey: Uint8List(10),
            clientSecretKey: SecureKeyFake.empty(5),
            serverPublicKey: Uint8List(5),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_kx_PUBLICKEYBYTES);
      });

      test('asserts if clientSecretKey is invalid', () {
        expect(
          () => sut.clientSessionKeys(
            clientPublicKey: Uint8List(5),
            clientSecretKey: SecureKeyFake.empty(10),
            serverPublicKey: Uint8List(5),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_kx_SECRETKEYBYTES);
      });

      test('asserts if serverPublicKey is invalid', () {
        expect(
          () => sut.clientSessionKeys(
            clientPublicKey: Uint8List(5),
            clientSecretKey: SecureKeyFake.empty(5),
            serverPublicKey: Uint8List(10),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_kx_PUBLICKEYBYTES).called(2);
      });

      test('calls crypto_kx_client_session_keys with correct arguments', () {
        when(
          () => mockSodium.crypto_kx_client_session_keys(
            any(),
            any(),
            any(),
          ),
        ).thenReturn(
          CryptoKX(
            sharedRx: Uint8List(0),
            sharedTx: Uint8List(0),
          ),
        );

        final clientPublicKey = List.generate(5, (index) => index);
        final clientSecretKey = List.generate(5, (index) => index + 50);
        final serverPublicKey = List.generate(5, (index) => index * index);

        sut.clientSessionKeys(
          clientPublicKey: Uint8List.fromList(clientPublicKey),
          clientSecretKey: SecureKeyFake(clientSecretKey),
          serverPublicKey: Uint8List.fromList(serverPublicKey),
        );

        verify(
          () => mockSodium.crypto_kx_client_session_keys(
            Uint8List.fromList(clientPublicKey),
            Uint8List.fromList(clientSecretKey),
            Uint8List.fromList(serverPublicKey),
          ),
        );
      });

      test('returns session keys', () {
        final rx = List.generate(10, (index) => index);
        final tx = List.generate(10, (index) => 20 - index);
        when(
          () => mockSodium.crypto_kx_client_session_keys(
            any(),
            any(),
            any(),
          ),
        ).thenReturn(
          CryptoKX(
            sharedRx: Uint8List.fromList(rx),
            sharedTx: Uint8List.fromList(tx),
          ),
        );

        final result = sut.clientSessionKeys(
          clientPublicKey: Uint8List(5),
          clientSecretKey: SecureKeyFake.empty(5),
          serverPublicKey: Uint8List(5),
        );

        expect(result.rx, SecureKeyFake(rx));
        expect(result.tx, SecureKeyFake(tx));
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_kx_client_session_keys(
            any(),
            any(),
            any(),
          ),
        ).thenThrow(JsError());

        expect(
          () => sut.clientSessionKeys(
            clientPublicKey: Uint8List(5),
            clientSecretKey: SecureKeyFake.empty(5),
            serverPublicKey: Uint8List(5),
          ),
          throwsA(isA<SodiumException>()),
        );
      });
    });

    group('serverSessionKeys', () {
      test('asserts if clientPublicKey is invalid', () {
        expect(
          () => sut.serverSessionKeys(
            serverPublicKey: Uint8List(10),
            serverSecretKey: SecureKeyFake.empty(5),
            clientPublicKey: Uint8List(5),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_kx_PUBLICKEYBYTES);
      });

      test('asserts if clientSecretKey is invalid', () {
        expect(
          () => sut.serverSessionKeys(
            serverPublicKey: Uint8List(5),
            serverSecretKey: SecureKeyFake.empty(10),
            clientPublicKey: Uint8List(5),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_kx_SECRETKEYBYTES);
      });

      test('asserts if serverPublicKey is invalid', () {
        expect(
          () => sut.serverSessionKeys(
            serverPublicKey: Uint8List(5),
            serverSecretKey: SecureKeyFake.empty(5),
            clientPublicKey: Uint8List(10),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_kx_PUBLICKEYBYTES).called(2);
      });

      test('calls crypto_kx_server_session_keys with correct arguments', () {
        when(
          () => mockSodium.crypto_kx_server_session_keys(
            any(),
            any(),
            any(),
          ),
        ).thenReturn(
          CryptoKX(
            sharedRx: Uint8List(0),
            sharedTx: Uint8List(0),
          ),
        );

        final serverPublicKey = List.generate(5, (index) => index);
        final serverSecretKey = List.generate(5, (index) => index + 50);
        final clientPublicKey = List.generate(5, (index) => index * index);

        sut.serverSessionKeys(
          serverPublicKey: Uint8List.fromList(serverPublicKey),
          serverSecretKey: SecureKeyFake(serverSecretKey),
          clientPublicKey: Uint8List.fromList(clientPublicKey),
        );

        verify(
          () => mockSodium.crypto_kx_server_session_keys(
            Uint8List.fromList(serverPublicKey),
            Uint8List.fromList(serverSecretKey),
            Uint8List.fromList(clientPublicKey),
          ),
        );
      });

      test('returns session keys', () {
        final rx = List.generate(10, (index) => index);
        final tx = List.generate(10, (index) => 20 - index);
        when(
          () => mockSodium.crypto_kx_server_session_keys(
            any(),
            any(),
            any(),
          ),
        ).thenReturn(
          CryptoKX(
            sharedRx: Uint8List.fromList(rx),
            sharedTx: Uint8List.fromList(tx),
          ),
        );

        final result = sut.serverSessionKeys(
          serverPublicKey: Uint8List(5),
          serverSecretKey: SecureKeyFake.empty(5),
          clientPublicKey: Uint8List(5),
        );

        expect(result.rx, SecureKeyFake(rx));
        expect(result.tx, SecureKeyFake(tx));
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_kx_server_session_keys(
            any(),
            any(),
            any(),
          ),
        ).thenThrow(JsError());

        expect(
          () => sut.serverSessionKeys(
            serverPublicKey: Uint8List(5),
            serverSecretKey: SecureKeyFake.empty(5),
            clientPublicKey: Uint8List(5),
          ),
          throwsA(isA<SodiumException>()),
        );
      });
    });
  });
}
