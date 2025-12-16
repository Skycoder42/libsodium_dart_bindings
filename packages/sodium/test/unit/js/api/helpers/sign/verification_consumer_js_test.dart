// ignore_for_file: unnecessary_lambdas for mocking

@TestOn('js')
library;

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/js/api/helpers/sign/verification_consumer_js.dart';
import 'package:sodium/src/js/bindings/js_error.dart';
import 'package:test/test.dart';

import '../../../sodium_js_mock.dart';
import 'sign_consumer_js_mixin_test_helpers.dart';

void main() {
  final publicKey = Uint8List.fromList(List.generate(5, (index) => index));
  final signature = Uint8List.fromList(
    List.generate(10, (index) => index + 100),
  );

  final mockSodium = MockLibSodiumJS();

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    reset(mockSodium);

    when(() => mockSodium.crypto_sign_BYTES).thenReturn(10);
  });

  group('constructor', () {
    test('calls crypto_sign_init', () {
      when(() => mockSodium.crypto_sign_init()).thenReturn(0.toJS);

      VerificationConsumerJS(
        sodium: mockSodium.asLibSodiumJS,
        publicKey: publicKey,
        signature: signature,
      );

      verify(() => mockSodium.crypto_sign_init());
    });

    test('throws SodiumException if crypto_sign_init fails', () {
      when(() => mockSodium.crypto_sign_init()).thenThrow(JSError());

      expect(
        () => VerificationConsumerJS(
          sodium: mockSodium.asLibSodiumJS,
          publicKey: publicKey,
          signature: signature,
        ),
        throwsA(isA<SodiumException>()),
      );
    });
  });

  group('members', () {
    const stateAddress = 42;
    late VerificationConsumerJS sut;

    setUp(() {
      when(() => mockSodium.crypto_sign_init()).thenReturn(stateAddress.toJS);

      sut = VerificationConsumerJS(
        sodium: mockSodium.asLibSodiumJS,
        publicKey: publicKey,
        signature: signature,
      );

      clearInteractions(mockSodium);
    });

    addStreamTests(
      mockSodium: mockSodium,
      createSut: () => sut,
      state: stateAddress,
      setUpVerify: () {
        when(
          () => mockSodium.crypto_sign_final_verify(any(), any(), any()),
        ).thenReturn(true);
      },
    );

    group('close', () {
      test('calls crypto_sign_final_verify with correct arguments', () async {
        when(
          () => mockSodium.crypto_sign_final_verify(any(), any(), any()),
        ).thenReturn(true);

        await sut.close();

        verify(
          () => mockSodium.crypto_sign_final_verify(
            stateAddress.toJS,
            signature.toJS,
            publicKey.toJS,
          ),
        );
      });

      test('returns validation result', () async {
        when(
          () => mockSodium.crypto_sign_final_verify(any(), any(), any()),
        ).thenReturn(true);

        final result = await sut.close();

        expect(result, isTrue);
      });

      test('throws exception if validation throws', () async {
        when(
          () => mockSodium.crypto_sign_final_verify(any(), any(), any()),
        ).thenThrow(JSError());

        await expectLater(() => sut.close(), throwsA(isA<SodiumException>()));
      });

      test('throws state error if close is called a second time', () async {
        when(
          () => mockSodium.crypto_sign_final_verify(any(), any(), any()),
        ).thenReturn(true);

        await sut.close();

        await expectLater(() => sut.close(), throwsA(isA<StateError>()));
      });

      test('returns same future as signatureValid', () async {
        when(
          () => mockSodium.crypto_sign_final_verify(any(), any(), any()),
        ).thenReturn(false);

        final signature = sut.signatureValid;

        final closed = sut.close();

        expect(signature, closed);
        expect(await signature, await closed);
      });
    });
  });
}
