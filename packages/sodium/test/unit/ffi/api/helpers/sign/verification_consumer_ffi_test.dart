// ignore_for_file: unnecessary_lambdas

@TestOn('dart-vm')
library;

import 'dart:ffi';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/ffi/api/helpers/sign/verification_consumer_ffi.dart';
import 'package:sodium/src/ffi/bindings/libsodium.ffi.dart';
import 'package:test/test.dart';

import '../../../pointer_test_helpers.dart';
import 'sign_consumer_ffi_mixin_test_helpers.dart';

class MockSodiumFFI extends Mock implements LibSodiumFFI {}

void main() {
  final publicKey = Uint8List.fromList(List.generate(5, (index) => index));
  final signature = Uint8List.fromList(
    List.generate(10, (index) => index + 100),
  );

  final mockSodium = MockSodiumFFI();

  setUpAll(() {
    registerPointers();
    registerFallbackValue(nullptr);
  });

  setUp(() {
    reset(mockSodium);

    mockAllocArray(mockSodium);

    when(() => mockSodium.crypto_sign_statebytes()).thenReturn(5);
    when(() => mockSodium.crypto_sign_bytes()).thenReturn(10);
  });

  group('constructor', () {
    initStateTests(
      mockSodium: mockSodium,
      createSut:
          () => VerificationConsumerFFI(
            sodium: mockSodium,
            publicKey: publicKey,
            signature: signature,
          ),
    );
  });

  group('members', () {
    late VerificationConsumerFFI sut;

    setUp(() {
      when(() => mockSodium.crypto_sign_init(any())).thenReturn(0);

      sut = VerificationConsumerFFI(
        sodium: mockSodium,
        publicKey: publicKey,
        signature: signature,
      );

      clearInteractions(mockSodium);
    });

    addStreamTests(
      mockSodium: mockSodium,
      createSut: () => sut,
      setUpVerify: () {
        when(
          () => mockSodium.crypto_sign_final_verify(any(), any(), any()),
        ).thenReturn(0);
      },
    );

    group('close', () {
      test('calls crypto_sign_final_verify with correct arguments', () async {
        when(
          () => mockSodium.crypto_sign_final_verify(any(), any(), any()),
        ).thenReturn(0);

        await sut.close();

        verifyInOrder([
          () => mockSodium.sodium_allocarray(10, 1),
          () => mockSodium.sodium_mprotect_readonly(
            any(that: hasRawData(signature)),
          ),
          () => mockSodium.sodium_allocarray(5, 1),
          () => mockSodium.sodium_mprotect_readonly(
            any(that: hasRawData(publicKey)),
          ),
          () => mockSodium.crypto_sign_final_verify(
            any(that: isNot(nullptr)),
            any(that: hasRawData(signature)),
            any(that: hasRawData(publicKey)),
          ),
        ]);
      });

      test('returns true on success', () async {
        when(
          () => mockSodium.crypto_sign_final_verify(any(), any(), any()),
        ).thenReturn(0);

        final result = await sut.close();

        expect(result, isTrue);
        verify(() => mockSodium.sodium_free(any())).called(3);
      });

      test('returns false on failure', () async {
        when(
          () => mockSodium.crypto_sign_final_verify(any(), any(), any()),
        ).thenReturn(1);

        final result = await sut.close();

        expect(result, isFalse);
        verify(() => mockSodium.sodium_free(any())).called(3);
      });

      test('throws exception if verification fails', () async {
        when(
          () => mockSodium.crypto_sign_final_verify(any(), any(), any()),
        ).thenThrow(SodiumException());

        await expectLater(() => sut.close(), throwsA(isA<SodiumException>()));

        verify(() => mockSodium.sodium_free(any())).called(3);
      });

      test('throws state error if close is called a second time', () async {
        when(
          () => mockSodium.crypto_sign_final_verify(any(), any(), any()),
        ).thenReturn(0);

        await sut.close();

        await expectLater(() => sut.close(), throwsA(isA<StateError>()));
      });

      test('returns same future as signatureValid', () async {
        when(
          () => mockSodium.crypto_sign_final_verify(any(), any(), any()),
        ).thenReturn(0);

        final signature = sut.signatureValid;

        final closed = sut.close();

        expect(signature, closed);
        expect(await signature, await closed);
      });
    });
  });
}
