// ignore_for_file: unnecessary_lambdas for mocking

@TestOn('dart-vm')
library;

import 'dart:ffi';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/ffi/api/helpers/sign/signature_consumer_ffi.dart';
import 'package:sodium/src/ffi/api/helpers/sign/verification_consumer_ffi.dart';
import 'package:sodium/src/ffi/api/sign_ffi.dart';
import 'package:sodium/src/ffi/bindings/libsodium.ffi.wrapper.dart';
import 'package:test/test.dart';

import '../../../secure_key_fake.dart';
import '../../../test_constants_mapping.dart';
import '../keygen_test_helpers.dart';
import '../pointer_test_helpers.dart';

class MockSodiumFFI extends Mock implements LibSodiumFFI {}

void main() {
  final mockSodium = MockSodiumFFI();

  late SignFFI sut;

  setUpAll(() {
    registerPointers();
    registerFallbackValue(nullptr);
  });

  setUp(() {
    reset(mockSodium);

    mockAllocArray(mockSodium);

    sut = SignFFI(mockSodium);
  });

  testConstantsMapping([
    (
      () => mockSodium.crypto_sign_publickeybytes(),
      () => sut.publicKeyBytes,
      'publicKeyBytes',
    ),
    (
      () => mockSodium.crypto_sign_secretkeybytes(),
      () => sut.secretKeyBytes,
      'secretKeyBytes',
    ),
    (() => mockSodium.crypto_sign_bytes(), () => sut.bytes, 'bytes'),
    (
      () => mockSodium.crypto_sign_seedbytes(),
      () => sut.seedBytes,
      'seedBytes',
    ),
  ]);

  group('methods', () {
    setUp(() {
      when(() => mockSodium.crypto_sign_publickeybytes()).thenReturn(5);
      when(() => mockSodium.crypto_sign_secretkeybytes()).thenReturn(5);
      when(() => mockSodium.crypto_sign_bytes()).thenReturn(5);
      when(() => mockSodium.crypto_sign_statebytes()).thenReturn(5);
    });

    testKeypair(
      mockSodium: mockSodium,
      runKeypair: () => sut.keyPair(),
      secretKeyBytesNative: mockSodium.crypto_sign_secretkeybytes,
      publicKeyBytesNative: mockSodium.crypto_sign_publickeybytes,
      keypairNative: mockSodium.crypto_sign_keypair,
    );

    testSeedKeypair(
      mockSodium: mockSodium,
      runSeedKeypair: (seed) => sut.seedKeyPair(seed),
      seedBytesNative: mockSodium.crypto_sign_seedbytes,
      secretKeyBytesNative: mockSodium.crypto_sign_secretkeybytes,
      publicKeyBytesNative: mockSodium.crypto_sign_publickeybytes,
      seedKeypairNative: mockSodium.crypto_sign_seed_keypair,
    );

    group('call', () {
      test('asserts if secretKey is invalid', () {
        expect(
          () => sut(message: Uint8List(20), secretKey: SecureKeyFake.empty(10)),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_sign_secretkeybytes());
      });

      test('calls crypto_sign with correct arguments', () {
        when(
          () => mockSodium.crypto_sign(any(), any(), any(), any(), any()),
        ).thenReturn(0);

        final message = List.generate(20, (index) => index * 2);
        final secretKey = List.generate(5, (index) => 30 + index);
        final signature = List.filled(5, 0);

        sut(
          message: Uint8List.fromList(message),
          secretKey: SecureKeyFake(secretKey),
        );

        verifyInOrder([
          () => mockSodium.sodium_mprotect_readonly(
            any(that: hasRawData(secretKey)),
          ),
          () => mockSodium.crypto_sign(
            any(that: hasRawData<UnsignedChar>(signature + message)),
            any(that: equals(nullptr)),
            any(that: hasRawData<UnsignedChar>(message)),
            message.length,
            any(that: hasRawData<UnsignedChar>(secretKey)),
          ),
        ]);
      });

      test('returns signed message', () {
        final signedMessage = List.generate(25, (index) => 100 - index);
        when(
          () => mockSodium.crypto_sign(any(), any(), any(), any(), any()),
        ).thenAnswer((i) {
          fillPointer(i.positionalArguments.first as Pointer, signedMessage);
          return 0;
        });

        final result = sut(
          message: Uint8List(20),
          secretKey: SecureKeyFake.empty(5),
        );

        expect(result, signedMessage);

        verify(() => mockSodium.sodium_free(any())).called(1);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_sign(any(), any(), any(), any(), any()),
        ).thenReturn(1);

        expect(
          () => sut(message: Uint8List(10), secretKey: SecureKeyFake.empty(5)),
          throwsA(isA<SodiumException>()),
        );

        verify(() => mockSodium.sodium_free(any())).called(2);
      });
    });

    group('open', () {
      test('asserts if signedMessage is invalid', () {
        expect(
          () => sut.open(signedMessage: Uint8List(3), publicKey: Uint8List(5)),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_sign_bytes());
      });

      test('asserts if publicKey is invalid', () {
        expect(
          () => sut.open(signedMessage: Uint8List(5), publicKey: Uint8List(10)),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_sign_publickeybytes());
      });

      test('calls crypto_sign_open with correct arguments', () {
        when(
          () => mockSodium.crypto_sign_open(any(), any(), any(), any(), any()),
        ).thenReturn(0);

        final signedMessage = List.generate(20, (index) => index * 2);
        final publicKey = List.generate(5, (index) => 30 + index);

        sut.open(
          signedMessage: Uint8List.fromList(signedMessage),
          publicKey: Uint8List.fromList(publicKey),
        );

        verifyInOrder([
          () => mockSodium.sodium_mprotect_readonly(
            any(that: hasRawData(publicKey)),
          ),
          () => mockSodium.crypto_sign_open(
            any(that: hasRawData<UnsignedChar>(signedMessage.sublist(5))),
            any(that: equals(nullptr)),
            any(that: hasRawData<UnsignedChar>(signedMessage)),
            signedMessage.length,
            any(that: hasRawData<UnsignedChar>(publicKey)),
          ),
        ]);
      });

      test('returns validated message', () {
        final message = List.generate(20, (index) => 100 - index);
        when(
          () => mockSodium.crypto_sign_open(any(), any(), any(), any(), any()),
        ).thenAnswer((i) {
          fillPointer(i.positionalArguments.first as Pointer, message);
          return 0;
        });

        final result = sut.open(
          signedMessage: Uint8List(25),
          publicKey: Uint8List(5),
        );

        expect(result, message);

        verify(() => mockSodium.sodium_free(any())).called(1);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_sign_open(any(), any(), any(), any(), any()),
        ).thenReturn(1);

        expect(
          () => sut.open(signedMessage: Uint8List(25), publicKey: Uint8List(5)),
          throwsA(isA<SodiumException>()),
        );

        verify(() => mockSodium.sodium_free(any())).called(2);
      });
    });

    group('detached', () {
      test('asserts if secretKey is invalid', () {
        expect(
          () => sut.detached(
            message: Uint8List(20),
            secretKey: SecureKeyFake.empty(10),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_sign_secretkeybytes());
      });

      test('calls crypto_sign with correct arguments', () {
        when(
          () => mockSodium.crypto_sign_detached(
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(0);

        final message = List.generate(20, (index) => index * 2);
        final secretKey = List.generate(5, (index) => 30 + index);

        sut.detached(
          message: Uint8List.fromList(message),
          secretKey: SecureKeyFake(secretKey),
        );

        verifyInOrder([
          () => mockSodium.sodium_mprotect_readonly(
            any(that: hasRawData(message)),
          ),
          () => mockSodium.sodium_mprotect_readonly(
            any(that: hasRawData(secretKey)),
          ),
          () => mockSodium.crypto_sign_detached(
            any(that: isNot(nullptr)),
            any(that: equals(nullptr)),
            any(that: hasRawData<UnsignedChar>(message)),
            message.length,
            any(that: hasRawData<UnsignedChar>(secretKey)),
          ),
        ]);
      });

      test('returns signature of message', () {
        final signature = List.generate(5, (index) => 100 - index);
        when(
          () => mockSodium.crypto_sign_detached(
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenAnswer((i) {
          fillPointer(i.positionalArguments.first as Pointer, signature);
          return 0;
        });

        final result = sut.detached(
          message: Uint8List(20),
          secretKey: SecureKeyFake.empty(5),
        );

        expect(result, signature);

        verify(() => mockSodium.sodium_free(any())).called(2);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_sign_detached(
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(1);

        expect(
          () => sut.detached(
            message: Uint8List(10),
            secretKey: SecureKeyFake.empty(5),
          ),
          throwsA(isA<SodiumException>()),
        );

        verify(() => mockSodium.sodium_free(any())).called(3);
      });
    });

    group('verifyDetached', () {
      test('asserts if signature is invalid', () {
        expect(
          () => sut.verifyDetached(
            message: Uint8List(20),
            signature: Uint8List(10),
            publicKey: Uint8List(5),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_sign_bytes());
      });

      test('asserts if publicKey is invalid', () {
        expect(
          () => sut.verifyDetached(
            message: Uint8List(20),
            signature: Uint8List(5),
            publicKey: Uint8List(10),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_sign_publickeybytes());
      });

      test('calls crypto_sign_verify_detached with correct arguments', () {
        when(
          () => mockSodium.crypto_sign_verify_detached(
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(0);

        final message = List.generate(20, (index) => index * 2);
        final signature = List.generate(5, (index) => index * 20);
        final publicKey = List.generate(5, (index) => 30 + index);

        sut.verifyDetached(
          message: Uint8List.fromList(message),
          signature: Uint8List.fromList(signature),
          publicKey: Uint8List.fromList(publicKey),
        );

        verifyInOrder([
          () => mockSodium.sodium_mprotect_readonly(
            any(that: hasRawData(message)),
          ),
          () => mockSodium.sodium_mprotect_readonly(
            any(that: hasRawData(signature)),
          ),
          () => mockSodium.sodium_mprotect_readonly(
            any(that: hasRawData(publicKey)),
          ),
          () => mockSodium.crypto_sign_verify_detached(
            any(that: hasRawData<UnsignedChar>(signature)),
            any(that: hasRawData<UnsignedChar>(message)),
            message.length,
            any(that: hasRawData<UnsignedChar>(publicKey)),
          ),
        ]);
      });

      test('returns successful validation result', () {
        when(
          () => mockSodium.crypto_sign_verify_detached(
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(0);

        final result = sut.verifyDetached(
          message: Uint8List(20),
          signature: Uint8List(5),
          publicKey: Uint8List(5),
        );

        expect(result, isTrue);

        verify(() => mockSodium.sodium_free(any())).called(3);
      });

      test('returns failure validation result', () {
        when(
          () => mockSodium.crypto_sign_verify_detached(
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(1);

        final result = sut.verifyDetached(
          message: Uint8List(20),
          signature: Uint8List(5),
          publicKey: Uint8List(5),
        );

        expect(result, isFalse);

        verify(() => mockSodium.sodium_free(any())).called(3);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_sign_verify_detached(
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenThrow(Exception());

        expect(
          () => sut.verifyDetached(
            message: Uint8List(20),
            signature: Uint8List(5),
            publicKey: Uint8List(5),
          ),
          throwsA(isA<Exception>()),
        );

        verify(() => mockSodium.sodium_free(any())).called(3);
      });
    });

    group('createConsumer', () {
      test('asserts if secretKey is invalid', () {
        expect(
          () => sut.createConsumer(secretKey: SecureKeyFake.empty(10)),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_sign_secretkeybytes());
      });

      test('returns SignatureConsumerFFI', () {
        when(() => mockSodium.crypto_sign_init(any())).thenReturn(0);

        final secretKey = List.generate(5, (index) => index * index);

        final result = sut.createConsumer(secretKey: SecureKeyFake(secretKey));

        expect(
          result,
          isA<SignatureConsumerFFI>()
              .having((c) => c.sodium, 'sodium', mockSodium)
              .having(
                (c) => c.secretKey.extractBytes(),
                'secretKey',
                secretKey,
              ),
        );
      });
    });

    group('createVerifyConsumer', () {
      test('asserts if signature is invalid', () {
        expect(
          () => sut.createVerifyConsumer(
            signature: Uint8List(10),
            publicKey: Uint8List(5),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_sign_bytes());
      });

      test('asserts if publicKey is invalid', () {
        expect(
          () => sut.createVerifyConsumer(
            signature: Uint8List(5),
            publicKey: Uint8List(10),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_sign_publickeybytes());
      });

      test('returns VerificationConsumerFFI', () {
        when(() => mockSodium.crypto_sign_init(any())).thenReturn(0);

        final signature = List.generate(5, (index) => index + 100);
        final publicKey = List.generate(5, (index) => index * index);

        final result = sut.createVerifyConsumer(
          signature: Uint8List.fromList(signature),
          publicKey: Uint8List.fromList(publicKey),
        );

        expect(
          result,
          isA<VerificationConsumerFFI>()
              .having((c) => c.sodium, 'sodium', mockSodium)
              .having(
                (c) => c.signature,
                'signature',
                Uint8List.fromList(signature),
              )
              .having(
                (c) => c.publicKey,
                'publicKey',
                Uint8List.fromList(publicKey),
              ),
        );
      });
    });
  });
}
