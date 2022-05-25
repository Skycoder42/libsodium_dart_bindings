@TestOn('dart-vm')

import 'dart:ffi';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/secure_key.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/ffi/api/kx_ffi.dart';
import 'package:sodium/src/ffi/bindings/libsodium.ffi.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

import '../../../secure_key_fake.dart';
import '../../../test_constants_mapping.dart';
import '../keygen_test_helpers.dart';
import '../pointer_test_helpers.dart';

class MockSodiumFFI extends Mock implements LibSodiumFFI {}

void main() {
  final mockSodium = MockSodiumFFI();

  late KxFFI sut;

  setUpAll(() {
    registerPointers();
  });

  setUp(() {
    reset(mockSodium);

    mockAllocArray(mockSodium);

    sut = KxFFI(mockSodium);
  });

  testConstantsMapping([
    Tuple3(
      () => mockSodium.crypto_kx_publickeybytes(),
      () => sut.publicKeyBytes,
      'publicKeyBytes',
    ),
    Tuple3(
      () => mockSodium.crypto_kx_secretkeybytes(),
      () => sut.secretKeyBytes,
      'secretKeyBytes',
    ),
    Tuple3(
      () => mockSodium.crypto_kx_seedbytes(),
      () => sut.seedBytes,
      'seedBytes',
    ),
    Tuple3(
      () => mockSodium.crypto_kx_sessionkeybytes(),
      () => sut.sessionKeyBytes,
      'sessionKeyBytes',
    ),
  ]);

  group('methods', () {
    setUp(() {
      when(() => mockSodium.crypto_kx_publickeybytes()).thenReturn(5);
      when(() => mockSodium.crypto_kx_secretkeybytes()).thenReturn(5);
      when(() => mockSodium.crypto_kx_seedbytes()).thenReturn(5);
      when(() => mockSodium.crypto_kx_sessionkeybytes()).thenReturn(10);
    });

    testKeypair(
      mockSodium: mockSodium,
      runKeypair: () => sut.keyPair(),
      secretKeyBytesNative: mockSodium.crypto_kx_secretkeybytes,
      publicKeyBytesNative: mockSodium.crypto_kx_publickeybytes,
      keypairNative: mockSodium.crypto_kx_keypair,
    );

    testSeedKeypair(
      mockSodium: mockSodium,
      runSeedKeypair: (SecureKey seed) => sut.seedKeyPair(seed),
      seedBytesNative: mockSodium.crypto_kx_seedbytes,
      secretKeyBytesNative: mockSodium.crypto_kx_secretkeybytes,
      publicKeyBytesNative: mockSodium.crypto_kx_publickeybytes,
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

        verify(() => mockSodium.crypto_kx_publickeybytes());
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

        verify(() => mockSodium.crypto_kx_secretkeybytes());
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

        verify(() => mockSodium.crypto_kx_publickeybytes()).called(2);
      });

      test('calls crypto_kx_client_session_keys with correct arguments', () {
        when(
          () => mockSodium.crypto_kx_client_session_keys(
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(0);

        final clientPublicKey = List.generate(5, (index) => index);
        final clientSecretKey = List.generate(5, (index) => index + 50);
        final serverPublicKey = List.generate(5, (index) => index * index);

        sut.clientSessionKeys(
          clientPublicKey: Uint8List.fromList(clientPublicKey),
          clientSecretKey: SecureKeyFake(clientSecretKey),
          serverPublicKey: Uint8List.fromList(serverPublicKey),
        );

        verifyInOrder([
          () => mockSodium.sodium_allocarray(10, 1),
          () => mockSodium.sodium_mprotect_noaccess(any(that: isNot(nullptr))),
          () => mockSodium.sodium_allocarray(10, 1),
          () => mockSodium.sodium_mprotect_noaccess(any(that: isNot(nullptr))),
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(clientPublicKey)),
              ),
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(serverPublicKey)),
              ),
          () => mockSodium.sodium_mprotect_readwrite(any(that: isNot(nullptr))),
          () => mockSodium.sodium_mprotect_readwrite(any(that: isNot(nullptr))),
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(clientSecretKey)),
              ),
          () => mockSodium.crypto_kx_client_session_keys(
                any(that: isNot(nullptr)),
                any(that: isNot(nullptr)),
                any(that: hasRawData<UnsignedChar>(clientPublicKey)),
                any(that: hasRawData<UnsignedChar>(clientSecretKey)),
                any(that: hasRawData<UnsignedChar>(serverPublicKey)),
              ),
          () => mockSodium.sodium_mprotect_noaccess(any(that: isNot(nullptr))),
          () => mockSodium.sodium_mprotect_noaccess(any(that: isNot(nullptr))),
        ]);
      });

      test('returns session keys', () {
        final rx = List.generate(10, (index) => index);
        final tx = List.generate(10, (index) => 20 - index);
        when(
          () => mockSodium.crypto_kx_client_session_keys(
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenAnswer((i) {
          fillPointer(i.positionalArguments[0] as Pointer, rx);
          fillPointer(i.positionalArguments[1] as Pointer, tx);
          return 0;
        });

        final result = sut.clientSessionKeys(
          clientPublicKey: Uint8List(5),
          clientSecretKey: SecureKeyFake.empty(5),
          serverPublicKey: Uint8List(5),
        );

        expect(result.rx, SecureKeyFake(rx));
        expect(result.tx, SecureKeyFake(tx));

        verify(
          () => mockSodium.sodium_free(any(that: isNot(nullptr))),
        ).called(3);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_kx_client_session_keys(
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(1);

        expect(
          () => sut.clientSessionKeys(
            clientPublicKey: Uint8List(5),
            clientSecretKey: SecureKeyFake.empty(5),
            serverPublicKey: Uint8List(5),
          ),
          throwsA(isA<SodiumException>()),
        );

        verify(
          () => mockSodium.sodium_free(any(that: isNot(nullptr))),
        ).called(5);
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

        verify(() => mockSodium.crypto_kx_publickeybytes());
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

        verify(() => mockSodium.crypto_kx_secretkeybytes());
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

        verify(() => mockSodium.crypto_kx_publickeybytes()).called(2);
      });

      test('calls crypto_kx_server_session_keys with correct arguments', () {
        when(
          () => mockSodium.crypto_kx_server_session_keys(
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(0);

        final serverPublicKey = List.generate(5, (index) => index);
        final serverSecretKey = List.generate(5, (index) => index + 50);
        final clientPublicKey = List.generate(5, (index) => index * index);

        sut.serverSessionKeys(
          serverPublicKey: Uint8List.fromList(serverPublicKey),
          serverSecretKey: SecureKeyFake(serverSecretKey),
          clientPublicKey: Uint8List.fromList(clientPublicKey),
        );

        verifyInOrder([
          () => mockSodium.sodium_allocarray(10, 1),
          () => mockSodium.sodium_mprotect_noaccess(any(that: isNot(nullptr))),
          () => mockSodium.sodium_allocarray(10, 1),
          () => mockSodium.sodium_mprotect_noaccess(any(that: isNot(nullptr))),
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(serverPublicKey)),
              ),
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(clientPublicKey)),
              ),
          () => mockSodium.sodium_mprotect_readwrite(any(that: isNot(nullptr))),
          () => mockSodium.sodium_mprotect_readwrite(any(that: isNot(nullptr))),
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(serverSecretKey)),
              ),
          () => mockSodium.crypto_kx_server_session_keys(
                any(that: isNot(nullptr)),
                any(that: isNot(nullptr)),
                any(that: hasRawData<UnsignedChar>(serverPublicKey)),
                any(that: hasRawData<UnsignedChar>(serverSecretKey)),
                any(that: hasRawData<UnsignedChar>(clientPublicKey)),
              ),
          () => mockSodium.sodium_mprotect_noaccess(any(that: isNot(nullptr))),
          () => mockSodium.sodium_mprotect_noaccess(any(that: isNot(nullptr))),
        ]);
      });

      test('returns session keys', () {
        final rx = List.generate(10, (index) => index);
        final tx = List.generate(10, (index) => 20 - index);
        when(
          () => mockSodium.crypto_kx_server_session_keys(
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenAnswer((i) {
          fillPointer(i.positionalArguments[0] as Pointer, rx);
          fillPointer(i.positionalArguments[1] as Pointer, tx);
          return 0;
        });

        final result = sut.serverSessionKeys(
          serverPublicKey: Uint8List(5),
          serverSecretKey: SecureKeyFake.empty(5),
          clientPublicKey: Uint8List(5),
        );

        expect(result.rx, SecureKeyFake(rx));
        expect(result.tx, SecureKeyFake(tx));

        verify(
          () => mockSodium.sodium_free(any(that: isNot(nullptr))),
        ).called(3);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_kx_server_session_keys(
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(1);

        expect(
          () => sut.serverSessionKeys(
            serverPublicKey: Uint8List(5),
            serverSecretKey: SecureKeyFake.empty(5),
            clientPublicKey: Uint8List(5),
          ),
          throwsA(isA<SodiumException>()),
        );

        verify(
          () => mockSodium.sodium_free(any(that: isNot(nullptr))),
        ).called(5);
      });
    });
  });
}
