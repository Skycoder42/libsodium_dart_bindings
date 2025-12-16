// ignore_for_file: unnecessary_lambdas for mocking

@TestOn('js')
library;

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/js/api/helpers/sign/signature_consumer_js.dart';
import 'package:sodium/src/js/api/helpers/sign/verification_consumer_js.dart';
import 'package:sodium/src/js/api/sign_js.dart';
import 'package:sodium/src/js/bindings/js_error.dart';
import 'package:test/test.dart';

import '../../../secure_key_fake.dart';
import '../../../test_constants_mapping.dart';
import '../keygen_test_helpers.dart';

import '../sodium_js_mock.dart';

void main() {
  final mockSodium = MockLibSodiumJS();

  late SignJS sut;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    reset(mockSodium);

    sut = SignJS(mockSodium.asLibSodiumJS);
  });

  testConstantsMapping([
    (
      () => mockSodium.crypto_sign_PUBLICKEYBYTES,
      () => sut.publicKeyBytes,
      'publicKeyBytes',
    ),
    (
      () => mockSodium.crypto_sign_SECRETKEYBYTES,
      () => sut.secretKeyBytes,
      'secretKeyBytes',
    ),
    (() => mockSodium.crypto_sign_BYTES, () => sut.bytes, 'bytes'),
    (() => mockSodium.crypto_sign_SEEDBYTES, () => sut.seedBytes, 'seedBytes'),
  ]);

  group('methods', () {
    setUp(() {
      when(() => mockSodium.crypto_sign_PUBLICKEYBYTES).thenReturn(5);
      when(() => mockSodium.crypto_sign_SECRETKEYBYTES).thenReturn(5);
      when(() => mockSodium.crypto_sign_BYTES).thenReturn(5);
    });

    testKeypair(
      mockSodium: mockSodium,
      runKeypair: () => sut.keyPair(),
      keypairNative: mockSodium.crypto_sign_keypair,
    );

    testSeedKeypair(
      mockSodium: mockSodium,
      runSeedKeypair: (seed) => sut.seedKeyPair(seed),
      seedBytesNative: () => mockSodium.crypto_sign_SEEDBYTES,
      seedKeypairNative: mockSodium.crypto_sign_seed_keypair,
    );

    group('call', () {
      test('asserts if secretKey is invalid', () {
        expect(
          () => sut(message: Uint8List(20), secretKey: SecureKeyFake.empty(10)),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_sign_SECRETKEYBYTES);
      });

      test('calls crypto_sign with correct arguments', () {
        when(
          () => mockSodium.crypto_sign(any(), any()),
        ).thenReturn(Uint8List(0).toJS);

        final message = List.generate(20, (index) => index * 2);
        final secretKey = List.generate(5, (index) => 30 + index);

        sut(
          message: Uint8List.fromList(message),
          secretKey: SecureKeyFake(secretKey),
        );

        verify(
          () => mockSodium.crypto_sign(
            Uint8List.fromList(message).toJS,
            Uint8List.fromList(secretKey).toJS,
          ),
        );
      });

      test('returns signed message', () {
        final signedMessage = List.generate(25, (index) => 100 - index);
        when(
          () => mockSodium.crypto_sign(any(), any()),
        ).thenReturn(Uint8List.fromList(signedMessage).toJS);

        final result = sut(
          message: Uint8List(20),
          secretKey: SecureKeyFake.empty(5),
        );

        expect(result, signedMessage);
      });

      test('throws exception on failure', () {
        when(() => mockSodium.crypto_sign(any(), any())).thenThrow(JSError());

        expect(
          () => sut(message: Uint8List(10), secretKey: SecureKeyFake.empty(5)),
          throwsA(isA<SodiumException>()),
        );
      });
    });

    group('open', () {
      test('asserts if signedMessage is invalid', () {
        expect(
          () => sut.open(signedMessage: Uint8List(3), publicKey: Uint8List(5)),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_sign_BYTES);
      });

      test('asserts if publicKey is invalid', () {
        expect(
          () => sut.open(signedMessage: Uint8List(5), publicKey: Uint8List(10)),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_sign_PUBLICKEYBYTES);
      });

      test('calls crypto_sign_open with correct arguments', () {
        when(
          () => mockSodium.crypto_sign_open(any(), any()),
        ).thenReturn(Uint8List(0).toJS);

        final signedMessage = List.generate(20, (index) => index * 2);
        final publicKey = List.generate(5, (index) => 30 + index);

        sut.open(
          signedMessage: Uint8List.fromList(signedMessage),
          publicKey: Uint8List.fromList(publicKey),
        );

        verify(
          () => mockSodium.crypto_sign_open(
            Uint8List.fromList(signedMessage).toJS,
            Uint8List.fromList(publicKey).toJS,
          ),
        );
      });

      test('returns validated message', () {
        final message = List.generate(20, (index) => 100 - index);
        when(
          () => mockSodium.crypto_sign_open(any(), any()),
        ).thenReturn(Uint8List.fromList(message).toJS);

        final result = sut.open(
          signedMessage: Uint8List(25),
          publicKey: Uint8List(5),
        );

        expect(result, message);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_sign_open(any(), any()),
        ).thenThrow(JSError());

        expect(
          () => sut.open(signedMessage: Uint8List(25), publicKey: Uint8List(5)),
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
          () => mockSodium.crypto_sign_detached(any(), any()),
        ).thenReturn(Uint8List(0).toJS);

        final message = List.generate(20, (index) => index * 2);
        final secretKey = List.generate(5, (index) => 30 + index);

        sut.detached(
          message: Uint8List.fromList(message),
          secretKey: SecureKeyFake(secretKey),
        );

        verify(
          () => mockSodium.crypto_sign_detached(
            Uint8List.fromList(message).toJS,
            Uint8List.fromList(secretKey).toJS,
          ),
        );
      });

      test('returns signature of message', () {
        final signature = List.generate(5, (index) => 100 - index);
        when(
          () => mockSodium.crypto_sign_detached(any(), any()),
        ).thenReturn(Uint8List.fromList(signature).toJS);

        final result = sut.detached(
          message: Uint8List(20),
          secretKey: SecureKeyFake.empty(5),
        );

        expect(result, signature);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_sign_detached(any(), any()),
        ).thenThrow(JSError());

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
          () => mockSodium.crypto_sign_verify_detached(any(), any(), any()),
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
            Uint8List.fromList(signature).toJS,
            Uint8List.fromList(message).toJS,
            Uint8List.fromList(publicKey).toJS,
          ),
        );
      });

      test('returns successful validation result', () {
        when(
          () => mockSodium.crypto_sign_verify_detached(any(), any(), any()),
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
          () => mockSodium.crypto_sign_verify_detached(any(), any(), any()),
        ).thenThrow(JSError());

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
          () => sut.createConsumer(secretKey: SecureKeyFake.empty(10)),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_sign_SECRETKEYBYTES);
      });

      test('returns SignatureConsumerFFI', () {
        when(() => mockSodium.crypto_sign_init()).thenReturn(0.toJS);

        final secretKey = List.generate(5, (index) => index * index);

        final result = sut.createConsumer(secretKey: SecureKeyFake(secretKey));

        expect(
          result,
          isA<SignatureConsumerJS>()
              .having((c) => c.sodium, 'sodium', sut.sodium)
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
        when(() => mockSodium.crypto_sign_init()).thenReturn(0.toJS);

        final signature = List.generate(5, (index) => index + 100);
        final publicKey = List.generate(5, (index) => index * index);

        final result = sut.createVerifyConsumer(
          signature: Uint8List.fromList(signature),
          publicKey: Uint8List.fromList(publicKey),
        );

        expect(
          result,
          isA<VerificationConsumerJS>()
              .having((c) => c.sodium, 'sodium', sut.sodium)
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
