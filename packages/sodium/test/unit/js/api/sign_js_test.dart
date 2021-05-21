import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/js/api/helpers/sign/signature_consumer_js.dart';
import 'package:sodium/src/js/api/helpers/sign/verification_consumer_js.dart';
import 'package:sodium/src/js/api/sign_js.dart';
import 'package:sodium/src/js/bindings/js_error.dart';
import 'package:sodium/src/js/bindings/sodium.js.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

import '../../../secure_key_fake.dart';
import '../../../test_constants_mapping.dart';

class MockLibSodiumJS extends Mock implements LibSodiumJS {}

void main() {
  final mockSodium = MockLibSodiumJS();

  late SignJS sut;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    reset(mockSodium);

    sut = SignJS(mockSodium);
  });

  testConstantsMapping([
    Tuple3(
      () => mockSodium.crypto_sign_PUBLICKEYBYTES,
      () => sut.publicKeyBytes,
      'publicKeyBytes',
    ),
    Tuple3(
      () => mockSodium.crypto_sign_SECRETKEYBYTES,
      () => sut.secretKeyBytes,
      'secretKeyBytes',
    ),
    Tuple3(
      () => mockSodium.crypto_sign_BYTES,
      () => sut.bytes,
      'bytes',
    ),
    Tuple3(
      () => mockSodium.crypto_sign_SEEDBYTES,
      () => sut.seedBytes,
      'seedBytes',
    ),
  ]);

  group('methods', () {
    setUp(() {
      when(() => mockSodium.crypto_sign_PUBLICKEYBYTES).thenReturn(5);
      when(() => mockSodium.crypto_sign_SECRETKEYBYTES).thenReturn(5);
      when(() => mockSodium.crypto_sign_BYTES).thenReturn(5);
      when(() => mockSodium.crypto_sign_SEEDBYTES).thenReturn(5);
    });

    group('keypair', () {
      test('calls crypto_sign_keypair to allocate keys', () {
        when(() => mockSodium.crypto_sign_keypair()).thenReturn(KeyPair(
          keyType: '',
          publicKey: Uint8List(0),
          privateKey: Uint8List(0),
        ));

        sut.keyPair();

        verify(() => mockSodium.crypto_sign_keypair());
      });

      test('returns generated key', () {
        final testPublic = List.generate(5, (index) => 10 - index);
        final testSecret = List.generate(5, (index) => index);
        when(() => mockSodium.crypto_sign_keypair()).thenReturn(KeyPair(
          keyType: '',
          publicKey: Uint8List.fromList(testPublic),
          privateKey: Uint8List.fromList(testSecret),
        ));

        final res = sut.keyPair();

        expect(res.publicKey, testPublic);
        expect(res.secretKey.extractBytes(), testSecret);
      });

      test('disposes allocated key on error', () {
        when(() => mockSodium.crypto_sign_keypair()).thenThrow(JsError());

        expect(() => sut.keyPair(), throwsA(isA<Exception>()));
      });
    });

    group('seedKeypair', () {
      test('asserts if seed is invalid', () {
        expect(
          () => sut.seedKeyPair(SecureKeyFake.empty(10)),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_sign_SEEDBYTES);
      });

      test('calls crypto_box_seed_keypair on the keys with the seed', () {
        when(() => mockSodium.crypto_sign_seed_keypair(any()))
            .thenReturn(KeyPair(
          keyType: '',
          publicKey: Uint8List(0),
          privateKey: Uint8List(0),
        ));

        final seed = List.generate(5, (index) => 3 * index);
        sut.seedKeyPair(SecureKeyFake(seed));

        verify(
          () => mockSodium.crypto_sign_seed_keypair(Uint8List.fromList(seed)),
        );
      });

      test('returns generated key', () {
        final testPublic = List.generate(5, (index) => 10 - index);
        final testSecret = List.generate(5, (index) => index);
        when(() => mockSodium.crypto_sign_seed_keypair(any()))
            .thenReturn(KeyPair(
          keyType: '',
          publicKey: Uint8List.fromList(testPublic),
          privateKey: Uint8List.fromList(testSecret),
        ));

        final res = sut.seedKeyPair(SecureKeyFake.empty(5));

        expect(res.publicKey, testPublic);
        expect(res.secretKey.extractBytes(), testSecret);
      });

      test('disposes allocated key on error', () {
        when(() => mockSodium.crypto_sign_seed_keypair(any()))
            .thenThrow(JsError());

        expect(
          () => sut.seedKeyPair(SecureKeyFake.empty(5)),
          throwsA(isA<Exception>()),
        );
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

        verify(() => mockSodium.crypto_sign_SECRETKEYBYTES);
      });

      test('calls crypto_sign with correct arguments', () {
        when(
          () => mockSodium.crypto_sign(
            any(),
            any(),
          ),
        ).thenReturn(Uint8List(0));

        final message = List.generate(20, (index) => index * 2);
        final secretKey = List.generate(5, (index) => 30 + index);

        sut(
          message: Uint8List.fromList(message),
          secretKey: SecureKeyFake(secretKey),
        );

        verify(
          () => mockSodium.crypto_sign(
            Uint8List.fromList(message),
            Uint8List.fromList(secretKey),
          ),
        );
      });

      test('returns signed message', () {
        final signedMessage = List.generate(25, (index) => 100 - index);
        when(
          () => mockSodium.crypto_sign(
            any(),
            any(),
          ),
        ).thenReturn(Uint8List.fromList(signedMessage));

        final result = sut(
          message: Uint8List(20),
          secretKey: SecureKeyFake.empty(5),
        );

        expect(result, signedMessage);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_sign(
            any(),
            any(),
          ),
        ).thenThrow(JsError());

        expect(
          () => sut(
            message: Uint8List(10),
            secretKey: SecureKeyFake.empty(5),
          ),
          throwsA(isA<SodiumException>()),
        );
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

        verify(() => mockSodium.crypto_sign_BYTES);
      });

      test('asserts if publicKey is invalid', () {
        expect(
          () => sut.open(
            signedMessage: Uint8List(5),
            publicKey: Uint8List(10),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_sign_PUBLICKEYBYTES);
      });

      test('calls crypto_sign_open with correct arguments', () {
        when(
          () => mockSodium.crypto_sign_open(
            any(),
            any(),
          ),
        ).thenReturn(Uint8List(0));

        final signedMessage = List.generate(20, (index) => index * 2);
        final publicKey = List.generate(5, (index) => 30 + index);

        sut.open(
          signedMessage: Uint8List.fromList(signedMessage),
          publicKey: Uint8List.fromList(publicKey),
        );

        verify(
          () => mockSodium.crypto_sign_open(
            Uint8List.fromList(signedMessage),
            Uint8List.fromList(publicKey),
          ),
        );
      });

      test('returns validated message', () {
        final message = List.generate(20, (index) => 100 - index);
        when(
          () => mockSodium.crypto_sign_open(
            any(),
            any(),
          ),
        ).thenReturn(Uint8List.fromList(message));

        final result = sut.open(
          signedMessage: Uint8List(25),
          publicKey: Uint8List(5),
        );

        expect(result, message);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_sign_open(
            any(),
            any(),
          ),
        ).thenThrow(JsError());

        expect(
          () => sut.open(
            signedMessage: Uint8List(25),
            publicKey: Uint8List(5),
          ),
          throwsA(isA<SodiumException>()),
        );
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

        verify(() => mockSodium.crypto_sign_SECRETKEYBYTES);
      });

      test('calls crypto_sign with correct arguments', () {
        when(
          () => mockSodium.crypto_sign_detached(
            any(),
            any(),
          ),
        ).thenReturn(Uint8List(0));

        final message = List.generate(20, (index) => index * 2);
        final secretKey = List.generate(5, (index) => 30 + index);

        sut.detached(
          message: Uint8List.fromList(message),
          secretKey: SecureKeyFake(secretKey),
        );

        verify(
          () => mockSodium.crypto_sign_detached(
            Uint8List.fromList(message),
            Uint8List.fromList(secretKey),
          ),
        );
      });

      test('returns signature of message', () {
        final signature = List.generate(5, (index) => 100 - index);
        when(
          () => mockSodium.crypto_sign_detached(
            any(),
            any(),
          ),
        ).thenReturn(Uint8List.fromList(signature));

        final result = sut.detached(
          message: Uint8List(20),
          secretKey: SecureKeyFake.empty(5),
        );

        expect(result, signature);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_sign_detached(
            any(),
            any(),
          ),
        ).thenThrow(JsError());

        expect(
          () => sut.detached(
            message: Uint8List(10),
            secretKey: SecureKeyFake.empty(5),
          ),
          throwsA(isA<SodiumException>()),
        );
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

        verify(() => mockSodium.crypto_sign_BYTES);
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

        verify(() => mockSodium.crypto_sign_PUBLICKEYBYTES);
      });

      test('calls crypto_sign_verify_detached with correct arguments', () {
        when(
          () => mockSodium.crypto_sign_verify_detached(
            any(),
            any(),
            any(),
          ),
        ).thenReturn(true);

        final message = List.generate(20, (index) => index * 2);
        final signature = List.generate(5, (index) => index * 20);
        final publicKey = List.generate(5, (index) => 30 + index);

        sut.verifyDetached(
          message: Uint8List.fromList(message),
          signature: Uint8List.fromList(signature),
          publicKey: Uint8List.fromList(publicKey),
        );

        verify(
          () => mockSodium.crypto_sign_verify_detached(
            Uint8List.fromList(signature),
            Uint8List.fromList(message),
            Uint8List.fromList(publicKey),
          ),
        );
      });

      test('returns successful validation result', () {
        when(
          () => mockSodium.crypto_sign_verify_detached(
            any(),
            any(),
            any(),
          ),
        ).thenReturn(true);

        final result = sut.verifyDetached(
          message: Uint8List(20),
          signature: Uint8List(5),
          publicKey: Uint8List(5),
        );

        expect(result, isTrue);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_sign_verify_detached(
            any(),
            any(),
            any(),
          ),
        ).thenThrow(JsError());

        expect(
          () => sut.verifyDetached(
            message: Uint8List(20),
            signature: Uint8List(5),
            publicKey: Uint8List(5),
          ),
          throwsA(isA<SodiumException>()),
        );
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

        verify(() => mockSodium.crypto_sign_SECRETKEYBYTES);
      });

      test('returns SignatureConsumerFFI', () {
        when(() => mockSodium.crypto_sign_init()).thenReturn(0);

        final secretKey = List.generate(5, (index) => index * index);

        final result = sut.createConsumer(
          secretKey: SecureKeyFake(secretKey),
        );

        expect(
          result,
          isA<SignatureConsumerJS>()
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

        verify(() => mockSodium.crypto_sign_BYTES);
      });

      test('asserts if publicKey is invalid', () {
        expect(
          () => sut.createVerifyConsumer(
            signature: Uint8List(5),
            publicKey: Uint8List(10),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_sign_PUBLICKEYBYTES);
      });

      test('returns VerificationConsumerFFI', () {
        when(() => mockSodium.crypto_sign_init()).thenReturn(0);

        final signature = List.generate(5, (index) => index + 100);
        final publicKey = List.generate(5, (index) => index * index);

        final result = sut.createVerifyConsumer(
          signature: Uint8List.fromList(signature),
          publicKey: Uint8List.fromList(publicKey),
        );

        expect(
          result,
          isA<VerificationConsumerJS>()
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
