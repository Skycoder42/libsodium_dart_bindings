import 'dart:ffi';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/ffi/api/helpers/sign/signature_consumer_ffi.dart';
import 'package:sodium/src/ffi/api/helpers/sign/verification_consumer_ffi.dart';
import 'package:sodium/src/ffi/api/sign_ffi.dart';
import 'package:sodium/src/ffi/bindings/libsodium.ffi.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

import '../../../secure_key_fake.dart';
import '../../../test_constants_mapping.dart';
import '../pointer_test_helpers.dart';

class MockSodiumFFI extends Mock implements LibSodiumFFI {}

void main() {
  final mockSodium = MockSodiumFFI();

  late SignFFI sut;

  setUpAll(() {
    registerPointers();
    registerFallbackValue<Pointer<crypto_sign_ed25519ph_state>>(nullptr);
  });

  setUp(() {
    reset(mockSodium);

    mockAllocArray(mockSodium);

    sut = SignFFI(mockSodium);
  });

  testConstantsMapping([
    Tuple3(
      () => mockSodium.crypto_sign_publickeybytes(),
      () => sut.publicKeyBytes,
      'publicKeyBytes',
    ),
    Tuple3(
      () => mockSodium.crypto_sign_secretkeybytes(),
      () => sut.secretKeyBytes,
      'secretKeyBytes',
    ),
    Tuple3(
      () => mockSodium.crypto_sign_bytes(),
      () => sut.bytes,
      'bytes',
    ),
    Tuple3(
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
      when(() => mockSodium.crypto_sign_seedbytes()).thenReturn(5);
      when(() => mockSodium.crypto_sign_statebytes()).thenReturn(5);
    });

    group('keypair', () {
      test('calls crypto_box_keypair on both allocated keys', () {
        when(() => mockSodium.crypto_sign_keypair(any(), any())).thenReturn(0);

        sut.keyPair();

        verifyInOrder([
          () => mockSodium.crypto_sign_secretkeybytes(),
          () => mockSodium.sodium_allocarray(5, 1),
          () => mockSodium.crypto_sign_publickeybytes(),
          () => mockSodium.sodium_allocarray(5, 1),
          () => mockSodium.sodium_mprotect_readwrite(any(that: isNot(nullptr))),
          () => mockSodium.crypto_sign_keypair(
                any(that: isNot(nullptr)),
                any(that: isNot(nullptr)),
              ),
          () => mockSodium.sodium_mprotect_noaccess(any(that: isNot(nullptr))),
        ]);
      });

      test('returns generated key', () {
        final testPublic = List.generate(5, (index) => 10 - index);
        final testSecret = List.generate(5, (index) => index);
        when(() => mockSodium.crypto_sign_keypair(any(), any()))
            .thenAnswer((i) {
          fillPointer(i.positionalArguments[0] as Pointer<Uint8>, testPublic);
          fillPointer(i.positionalArguments[1] as Pointer<Uint8>, testSecret);
          return 0;
        });

        final res = sut.keyPair();

        expect(res.publicKey, testPublic);
        expect(res.secretKey.extractBytes(), testSecret);

        verify(() => mockSodium.sodium_free(any(that: hasRawData(testPublic))));
      });

      test('disposes allocated key on error', () {
        when(() => mockSodium.crypto_sign_keypair(any(), any())).thenReturn(1);

        expect(() => sut.keyPair(), throwsA(isA<Exception>()));

        verify(
          () => mockSodium.sodium_free(any(that: isNot(nullptr))),
        ).called(2);
      });
    });

    group('seedKeypair', () {
      test('asserts if seed is invalid', () {
        expect(
          () => sut.seedKeyPair(SecureKeyFake.empty(10)),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_sign_seedbytes());
      });

      test('calls crypto_box_seed_keypair on the keys with the seed', () {
        when(() => mockSodium.crypto_sign_seed_keypair(any(), any(), any()))
            .thenReturn(0);

        final seed = List.generate(5, (index) => 3 * index);
        sut.seedKeyPair(SecureKeyFake(seed));

        verifyInOrder([
          () => mockSodium.crypto_sign_secretkeybytes(),
          () => mockSodium.sodium_allocarray(5, 1),
          () => mockSodium.crypto_sign_publickeybytes(),
          () => mockSodium.sodium_allocarray(5, 1),
          () => mockSodium.sodium_mprotect_readwrite(
                any(that: isNot(hasRawData(seed))),
              ),
          () => mockSodium.crypto_sign_seed_keypair(
                any(that: isNot(nullptr)),
                any(that: isNot(nullptr)),
                any(that: hasRawData<Uint8>(seed)),
              ),
          () => mockSodium.sodium_mprotect_noaccess(
                any(that: isNot(hasRawData(seed))),
              ),
        ]);
      });

      test('returns generated key', () {
        final testPublic = List.generate(5, (index) => 10 - index);
        final testSecret = List.generate(5, (index) => index);
        when(() => mockSodium.crypto_sign_seed_keypair(any(), any(), any()))
            .thenAnswer((i) {
          fillPointer(i.positionalArguments[0] as Pointer<Uint8>, testPublic);
          fillPointer(i.positionalArguments[1] as Pointer<Uint8>, testSecret);
          return 0;
        });

        final res = sut.seedKeyPair(SecureKeyFake.empty(5));

        expect(res.publicKey, testPublic);
        expect(res.secretKey.extractBytes(), testSecret);

        verify(() => mockSodium.sodium_free(any(that: hasRawData(testPublic))));
      });

      test('disposes allocated key on error', () {
        when(() => mockSodium.crypto_sign_seed_keypair(any(), any(), any()))
            .thenReturn(1);

        expect(
          () => sut.seedKeyPair(SecureKeyFake.empty(5)),
          throwsA(isA<Exception>()),
        );

        verify(
          () => mockSodium.sodium_free(any(that: isNot(nullptr))),
        ).called(3);
      });
    });

    group('call', () {
      test('asserts if secretKey is invalid', () {
        expect(
          () => sut(
            message: Uint8List(20),
            secretKey: SecureKeyFake.empty(10),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_sign_secretkeybytes());
      });

      test('calls crypto_sign with correct arguments', () {
        when(
          () => mockSodium.crypto_sign(
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
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
                any(that: hasRawData<Uint8>(signature + message)),
                any(that: equals(nullptr)),
                any(that: hasRawData<Uint8>(message)),
                message.length,
                any(that: hasRawData<Uint8>(secretKey)),
              ),
        ]);
      });

      test('returns signed message', () {
        final signedMessage = List.generate(25, (index) => 100 - index);
        when(
          () => mockSodium.crypto_sign(
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenAnswer((i) {
          fillPointer(i.positionalArguments.first as Pointer, signedMessage);
          return 0;
        });

        final result = sut(
          message: Uint8List(20),
          secretKey: SecureKeyFake.empty(5),
        );

        expect(result, signedMessage);

        verify(() => mockSodium.sodium_free(any())).called(2);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_sign(
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(1);

        expect(
          () => sut(
            message: Uint8List(10),
            secretKey: SecureKeyFake.empty(5),
          ),
          throwsA(isA<SodiumException>()),
        );

        verify(() => mockSodium.sodium_free(any())).called(2);
      });
    });

    group('open', () {
      test('asserts if signedMessage is invalid', () {
        expect(
          () => sut.open(
            signedMessage: Uint8List(3),
            publicKey: Uint8List(5),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_sign_bytes());
      });

      test('asserts if publicKey is invalid', () {
        expect(
          () => sut.open(
            signedMessage: Uint8List(5),
            publicKey: Uint8List(10),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_sign_publickeybytes());
      });

      test('calls crypto_sign_open with correct arguments', () {
        when(
          () => mockSodium.crypto_sign_open(
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
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
                any(that: hasRawData<Uint8>(signedMessage.sublist(5))),
                any(that: equals(nullptr)),
                any(that: hasRawData<Uint8>(signedMessage)),
                signedMessage.length,
                any(that: hasRawData<Uint8>(publicKey)),
              ),
        ]);
      });

      test('returns validated message', () {
        final message = List.generate(20, (index) => 100 - index);
        when(
          () => mockSodium.crypto_sign_open(
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenAnswer((i) {
          fillPointer(i.positionalArguments.first as Pointer, message);
          return 0;
        });

        final result = sut.open(
          signedMessage: Uint8List(25),
          publicKey: Uint8List(5),
        );

        expect(result, message);

        verify(() => mockSodium.sodium_free(any())).called(2);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_sign_open(
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(1);

        expect(
          () => sut.open(
            signedMessage: Uint8List(25),
            publicKey: Uint8List(5),
          ),
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
                any(that: hasRawData<Uint8>(message)),
                message.length,
                any(that: hasRawData<Uint8>(secretKey)),
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

        verify(() => mockSodium.sodium_free(any())).called(3);
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
                any(that: hasRawData<Uint8>(signature)),
                any(that: hasRawData<Uint8>(message)),
                message.length,
                any(that: hasRawData<Uint8>(publicKey)),
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
          () => sut.createConsumer(
            secretKey: SecureKeyFake.empty(10),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_sign_secretkeybytes());
      });

      test('returns SignatureConsumerFFI', () {
        when(() => mockSodium.crypto_sign_init(any())).thenReturn(0);

        final secretKey = List.generate(5, (index) => index * index);

        final result = sut.createConsumer(
          secretKey: SecureKeyFake(secretKey),
        );

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
