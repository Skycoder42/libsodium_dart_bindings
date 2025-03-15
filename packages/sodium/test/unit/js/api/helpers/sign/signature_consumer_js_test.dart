// ignore_for_file: unnecessary_lambdas

@TestOn('js')
library;

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/secure_key.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/js/api/helpers/sign/signature_consumer_js.dart';
import 'package:sodium/src/js/bindings/js_error.dart';
import 'package:test/test.dart';

import '../../../../../secure_key_fake.dart';
import '../../../sodium_js_mock.dart';
import 'sign_consumer_js_mixin_test_helpers.dart';

class MockSecureKey extends Mock implements SecureKey {}

void main() {
  final mockSodium = MockLibSodiumJS();

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    reset(mockSodium);

    when(() => mockSodium.crypto_sign_BYTES).thenReturn(10);
  });

  group('constructor', () {
    final mockSecretKey = MockSecureKey();

    setUp(() {
      reset(mockSecretKey);
    });

    test('creates copy of secretKey and calls crypto_sign_init', () {
      when(() => mockSecretKey.copy()).thenReturn(SecureKeyFake.empty(0));
      when(() => mockSodium.crypto_sign_init()).thenReturn(0.toJS);

      SignatureConsumerJS(
        sodium: mockSodium.asLibSodiumJS,
        secretKey: mockSecretKey,
      );

      verify(() => mockSecretKey.copy());
      verify(() => mockSodium.crypto_sign_init());
    });

    test('disposes copy of secretKey if crypto_sign_init fails', () {
      final mockKeyCopy = MockSecureKey();
      when(() => mockSecretKey.copy()).thenReturn(mockKeyCopy);
      when(() => mockSodium.crypto_sign_init()).thenThrow(JSError());

      expect(
        () => SignatureConsumerJS(
          sodium: mockSodium.asLibSodiumJS,
          secretKey: mockSecretKey,
        ),
        throwsA(isA<SodiumException>()),
      );

      verify(() => mockKeyCopy.dispose());
    });
  });

  group('members', () {
    const stateAddress = 42;
    final secretKey = SecureKeyFake(List.generate(20, (index) => 40 - index));

    late SignatureConsumerJS sut;

    setUp(() {
      when(() => mockSodium.crypto_sign_init()).thenReturn(stateAddress.toJS);

      sut = SignatureConsumerJS(
        sodium: mockSodium.asLibSodiumJS,
        secretKey: secretKey,
      );

      clearInteractions(mockSodium);
    });

    addStreamTests(
      mockSodium: mockSodium,
      createSut: () => sut,
      state: stateAddress,
      setUpVerify: () {
        when(
          () => mockSodium.crypto_sign_final_create(any(), any()),
        ).thenReturn(Uint8List(0).toJS);
      },
    );

    group('close', () {
      test('calls crypto_sign_final_create with correct arguments', () async {
        when(
          () => mockSodium.crypto_sign_final_create(any(), any()),
        ).thenReturn(Uint8List(0).toJS);

        await sut.close();

        verify(
          () => mockSodium.crypto_sign_final_create(
            stateAddress.toJS,
            secretKey.data.toJS,
          ),
        );
      });

      test('returns signature on success', () async {
        final signature = List.generate(10, (index) => index * 10);

        when(
          () => mockSodium.crypto_sign_final_create(any(), any()),
        ).thenReturn(Uint8List.fromList(signature).toJS);

        final result = await sut.close();

        expect(result, Uint8List.fromList(signature));
      });

      test('throws exception if signing fails', () async {
        when(
          () => mockSodium.crypto_sign_final_create(any(), any()),
        ).thenThrow(JSError());

        await expectLater(() => sut.close(), throwsA(isA<SodiumException>()));
      });

      test('throws state error if close is called a second time', () async {
        when(
          () => mockSodium.crypto_sign_final_create(any(), any()),
        ).thenReturn(Uint8List(0).toJS);

        await sut.close();

        await expectLater(() => sut.close(), throwsA(isA<StateError>()));
      });

      test('returns same future as signature', () async {
        when(
          () => mockSodium.crypto_sign_final_create(any(), any()),
        ).thenReturn(Uint8List(0).toJS);

        final signature = sut.signature;

        final closed = sut.close();

        expect(signature, closed);
        expect(await signature, await closed);
      });
    });
  });
}
