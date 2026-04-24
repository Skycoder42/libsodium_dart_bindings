// ignore_for_file: unnecessary_lambdas to catch member access errors

@TestOn('dart-vm')
library;

import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/ffi/api/kem_ffi.dart';
import 'package:sodium/src/ffi/bindings/libsodium.ffi.wrapper.dart';
import 'package:test/test.dart';

import '../../../secure_key_fake.dart';
import '../../../test_constants_mapping.dart';
import '../keygen_test_helpers.dart';
import '../pointer_test_helpers.dart';

class MockSodiumFFI extends Mock implements LibSodiumFFI {}

void main() {
  final mockSodium = MockSodiumFFI();

  late KemFFI sut;

  setUpAll(() {
    registerPointers();
  });

  setUp(() {
    reset(mockSodium);
    mockAllocArray(mockSodium);
    sut = KemFFI(mockSodium);
  });

  testConstantsMapping([
    (
      () => mockSodium.crypto_kem_publickeybytes(),
      () => sut.publicKeyBytes,
      'publicKeyBytes',
    ),
    (
      () => mockSodium.crypto_kem_secretkeybytes(),
      () => sut.secretKeyBytes,
      'secretKeyBytes',
    ),
    (
      () => mockSodium.crypto_kem_ciphertextbytes(),
      () => sut.ciphertextBytes,
      'ciphertextBytes',
    ),
    (
      () => mockSodium.crypto_kem_sharedsecretbytes(),
      () => sut.sharedSecretBytes,
      'sharedSecretBytes',
    ),
    (() => mockSodium.crypto_kem_seedbytes(), () => sut.seedBytes, 'seedBytes'),
  ]);

  test('maps primitive correctly', () {
    final ptr = 'xwing'.toNativeUtf8();
    addTearDown(() => calloc.free(ptr));
    when(() => mockSodium.crypto_kem_primitive()).thenReturn(ptr.cast());

    expect(sut.primitive, 'xwing');
    verify(() => mockSodium.crypto_kem_primitive());
  });

  group('methods', () {
    setUp(() {
      when(() => mockSodium.crypto_kem_publickeybytes()).thenReturn(5);
      when(() => mockSodium.crypto_kem_secretkeybytes()).thenReturn(5);
      when(() => mockSodium.crypto_kem_ciphertextbytes()).thenReturn(5);
      when(() => mockSodium.crypto_kem_sharedsecretbytes()).thenReturn(5);
      when(() => mockSodium.crypto_kem_seedbytes()).thenReturn(5);
    });

    testKeypair(
      mockSodium: mockSodium,
      runKeypair: () => sut.keyPair(),
      secretKeyBytesNative: mockSodium.crypto_kem_secretkeybytes,
      publicKeyBytesNative: mockSodium.crypto_kem_publickeybytes,
      keypairNative: mockSodium.crypto_kem_keypair,
    );

    testSeedKeypair(
      mockSodium: mockSodium,
      runSeedKeypair: (seed) => sut.seedKeyPair(seed),
      seedBytesNative: mockSodium.crypto_kem_seedbytes,
      secretKeyBytesNative: mockSodium.crypto_kem_secretkeybytes,
      publicKeyBytesNative: mockSodium.crypto_kem_publickeybytes,
      seedKeypairNative: mockSodium.crypto_kem_seed_keypair,
    );

    group('enc', () {
      test('asserts if publicKey is invalid', () {
        expect(
          () => sut.enc(publicKey: Uint8List(10)),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_kem_publickeybytes());
      });

      test('calls crypto_kem_enc with correct arguments', () {
        when(
          () => mockSodium.crypto_kem_enc(any(), any(), any()),
        ).thenReturn(0);

        final publicKey = List.generate(5, (i) => i);
        sut.enc(publicKey: Uint8List.fromList(publicKey));

        verifyInOrder([
          () => mockSodium.crypto_kem_enc(
            any(that: isNot(nullptr)),
            any(that: isNot(nullptr)),
            any(that: hasRawData<UnsignedChar>(publicKey)),
          ),
        ]);
      });

      test('returns enc result', () {
        final ctData = List.generate(5, (i) => i + 10);
        final ssData = List.generate(5, (i) => i + 20);

        when(() => mockSodium.crypto_kem_enc(any(), any(), any())).thenAnswer((
          i,
        ) {
          fillPointer(
            i.positionalArguments[0] as Pointer<UnsignedChar>,
            ctData,
          );
          fillPointer(
            i.positionalArguments[1] as Pointer<UnsignedChar>,
            ssData,
          );
          return 0;
        });

        final result = sut.enc(publicKey: Uint8List(5));

        expect(result.ciphertext, ctData);
        expect(result.sharedSecret.extractBytes(), ssData);

        // Only pkPtr is freed in the success path (finally block)
        verify(() => mockSodium.sodium_free(any())).called(1);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_kem_enc(any(), any(), any()),
        ).thenReturn(1);

        expect(
          () => sut.enc(publicKey: Uint8List(5)),
          throwsA(isA<SodiumException>()),
        );

        // ctPtr + ssKey (catch) + pkPtr (finally)
        verify(() => mockSodium.sodium_free(any())).called(3);
      });
    });

    group('dec', () {
      test('asserts if ciphertext is invalid', () {
        expect(
          () => sut.dec(
            ciphertext: Uint8List(10),
            secretKey: SecureKeyFake.empty(5),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_kem_ciphertextbytes());
      });

      test('asserts if secretKey is invalid', () {
        expect(
          () => sut.dec(
            ciphertext: Uint8List(5),
            secretKey: SecureKeyFake.empty(10),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_kem_secretkeybytes());
      });

      test('calls crypto_kem_dec with correct arguments', () {
        when(
          () => mockSodium.crypto_kem_dec(any(), any(), any()),
        ).thenReturn(0);

        final ctData = List.generate(5, (i) => i);
        final skData = List.generate(5, (i) => i + 50);

        sut.dec(
          ciphertext: Uint8List.fromList(ctData),
          secretKey: SecureKeyFake(skData),
        );

        verifyInOrder([
          () => mockSodium.crypto_kem_dec(
            any(that: isNot(nullptr)),
            any(that: hasRawData<UnsignedChar>(ctData)),
            any(that: hasRawData<UnsignedChar>(skData)),
          ),
        ]);
      });

      test('returns shared secret', () {
        final ssData = List.generate(5, (i) => i + 30);

        when(() => mockSodium.crypto_kem_dec(any(), any(), any())).thenAnswer((
          i,
        ) {
          fillPointer(
            i.positionalArguments[0] as Pointer<UnsignedChar>,
            ssData,
          );
          return 0;
        });

        final result = sut.dec(
          ciphertext: Uint8List(5),
          secretKey: SecureKeyFake.empty(5),
        );

        expect(result.extractBytes(), ssData);

        // ctPtr (finally) + temp pointer for SecureKeyFake (extension)
        verify(() => mockSodium.sodium_free(any())).called(2);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_kem_dec(any(), any(), any()),
        ).thenReturn(1);

        expect(
          () => sut.dec(
            ciphertext: Uint8List(5),
            secretKey: SecureKeyFake.empty(5),
          ),
          throwsA(isA<SodiumException>()),
        );

        // ssKey (catch) + ctPtr (finally) + temp pointer for SecureKeyFake
        verify(() => mockSodium.sodium_free(any())).called(3);
      });
    });
  });
}
