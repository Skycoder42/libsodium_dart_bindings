// ignore_for_file: unnecessary_lambdas for mocking

@TestOn('dart-vm')
library;

import 'dart:ffi';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/secure_key.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/ffi/api/helpers/sign/signature_consumer_ffi.dart';
import 'package:sodium/src/ffi/bindings/libsodium.ffi.wrapper.dart';
import 'package:test/test.dart';

import '../../../../../secure_key_fake.dart';
import '../../../pointer_test_helpers.dart';
import 'sign_consumer_ffi_mixin_test_helpers.dart';

class MockSodiumFFI extends Mock implements LibSodiumFFI {}

class MockSecureKey extends Mock implements SecureKey {}

void main() {
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
    final mockSecretKey = MockSecureKey();

    setUp(() {
      reset(mockSecretKey);
    });

    test('creates copy of secretKey', () {
      when(() => mockSecretKey.copy()).thenReturn(SecureKeyFake.empty(0));
      when(() => mockSodium.crypto_sign_init(any())).thenReturn(0);

      SignatureConsumerFFI(sodium: mockSodium, secretKey: mockSecretKey);

      verify(() => mockSecretKey.copy());
    });

    test('disposes copy of secretKey if init fails', () {
      final mockKeyCopy = MockSecureKey();
      when(() => mockSecretKey.copy()).thenReturn(mockKeyCopy);
      when(() => mockSodium.crypto_sign_init(any())).thenReturn(1);

      expect(
        () =>
            SignatureConsumerFFI(sodium: mockSodium, secretKey: mockSecretKey),
        throwsA(isA<SodiumException>()),
      );

      verify(() => mockKeyCopy.dispose());
    });

    initStateTests(
      mockSodium: mockSodium,
      createSut: () =>
          SignatureConsumerFFI(sodium: mockSodium, secretKey: mockSecretKey),
      setUp: () {
        when(() => mockSecretKey.copy()).thenReturn(SecureKeyFake.empty(0));
      },
    );
  });

  group('members', () {
    final secretKey = SecureKeyFake(List.generate(20, (index) => 40 - index));

    late SignatureConsumerFFI sut;

    setUp(() {
      when(() => mockSodium.crypto_sign_init(any())).thenReturn(0);

      sut = SignatureConsumerFFI(sodium: mockSodium, secretKey: secretKey);

      clearInteractions(mockSodium);
    });

    addStreamTests(
      mockSodium: mockSodium,
      createSut: () => sut,
      setUpVerify: () {
        when(
          () => mockSodium.crypto_sign_final_create(any(), any(), any(), any()),
        ).thenReturn(0);
      },
    );

    group('close', () {
      test('calls crypto_sign_final_create with correct arguments', () async {
        when(
          () => mockSodium.crypto_sign_final_create(any(), any(), any(), any()),
        ).thenReturn(0);

        await sut.close();

        verifyInOrder([
          () => mockSodium.sodium_allocarray(10, 1),
          () => mockSodium.sodium_memzero(any(that: isNot(nullptr)), 10),
          () => mockSodium.sodium_mprotect_readonly(
            any(that: hasRawData(secretKey.data)),
          ),
          () => mockSodium.crypto_sign_final_create(
            any(that: isNot(nullptr)),
            any(that: isNot(nullptr)),
            any(that: equals(nullptr)),
            any(that: hasRawData<UnsignedChar>(secretKey.data)),
          ),
        ]);
      });

      test('returns signature on success', () async {
        final signature = List.generate(10, (index) => index * 10);

        when(
          () => mockSodium.crypto_sign_final_create(any(), any(), any(), any()),
        ).thenAnswer((i) {
          fillPointer(i.positionalArguments[1] as Pointer, signature);
          return 0;
        });

        final result = await sut.close();

        expect(result, Uint8List.fromList(signature));
        verify(() => mockSodium.sodium_free(any())).called(2);
      });

      test('throws exception if signing fails', () async {
        when(
          () => mockSodium.crypto_sign_final_create(any(), any(), any(), any()),
        ).thenReturn(1);

        await expectLater(() => sut.close(), throwsA(isA<SodiumException>()));

        verify(() => mockSodium.sodium_free(any())).called(3);
      });

      test('throws state error if close is called a second time', () async {
        when(
          () => mockSodium.crypto_sign_final_create(any(), any(), any(), any()),
        ).thenReturn(0);

        await sut.close();

        await expectLater(() => sut.close(), throwsA(isA<StateError>()));
      });

      test('returns same future as signature', () async {
        when(
          () => mockSodium.crypto_sign_final_create(any(), any(), any(), any()),
        ).thenReturn(0);

        final signature = sut.signature;

        final closed = sut.close();

        expect(signature, closed);
        expect(await signature, await closed);
      });
    });
  });
}
