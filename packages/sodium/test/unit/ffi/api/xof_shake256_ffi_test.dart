// ignore_for_file: unnecessary_lambdas for mocking

@TestOn('dart-vm')
library;

import 'dart:ffi';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/ffi/api/helpers/xof/xof_consumer_ffi.dart';
import 'package:sodium/src/ffi/api/xof_shake256_ffi.dart';
import 'package:sodium/src/ffi/bindings/libsodium.ffi.dart'
    show crypto_xof_shake256_state;
import 'package:sodium/src/ffi/bindings/libsodium.ffi.wrapper.dart';
import 'package:test/test.dart';

import '../../../test_constants_mapping.dart';
import '../pointer_test_helpers.dart';

class MockSodiumFFI extends Mock implements LibSodiumFFI;

void main() {
  const stateBytes = 5;
  const outLen = 10;

  final mockSodium = MockSodiumFFI();

  late XofShake256FFI sut;

  setUpAll(() {
    registerPointers();
  });

  setUp(() {
    reset(mockSodium);

    mockAllocArray(mockSodium);

    sut = XofShake256FFI(mockSodium);
  });

  testConstantsMapping([
    (
      () => mockSodium.crypto_xof_shake256_blockbytes(),
      () => sut.blockBytes,
      'blockBytes',
    ),
    (
      () => mockSodium.crypto_xof_shake256_statebytes(),
      () => sut.stateBytes,
      'stateBytes',
    ),
    (
      () => mockSodium.crypto_xof_shake256_domain_standard(),
      () => sut.domainStandard,
      'domainStandard',
    ),
  ]);

  group('methods', () {
    setUp(() {
      when(() => mockSodium.crypto_xof_shake256_blockbytes()).thenReturn(5);
      when(() => mockSodium.crypto_xof_shake256_statebytes())
          .thenReturn(stateBytes);
      when(() => mockSodium.crypto_xof_shake256_domain_standard())
          .thenReturn(0x1F);
    });

    group('call', () {
      test('asserts if outLen is invalid', () {
        expect(
          () => sut(message: Uint8List(20), outLen: 0),
          throwsA(isA<RangeError>()),
        );

        verifyNever(
          () => mockSodium.crypto_xof_shake256(any(), any(), any(), any()),
        );
      });

      test('calls crypto_xof_shake256 with correct arguments', () {
        when(() => mockSodium.crypto_xof_shake256(any(), any(), any(), any()))
            .thenReturn(0);

        final message = List.generate(20, (index) => index * 3);

        sut(message: Uint8List.fromList(message), outLen: outLen);

        verifyInOrder([
          () => mockSodium.sodium_allocarray(outLen, 1),
          () => mockSodium.sodium_mprotect_readonly(
            any(that: hasRawData(message)),
          ),
          () => mockSodium.crypto_xof_shake256(
            any(that: isNot(nullptr)),
            outLen,
            any(that: hasRawData<UnsignedChar>(message)),
            message.length,
          ),
        ]);
      });

      test('returns the generated output', () {
        final output = List.generate(outLen, (index) => 100 - index);

        when(() => mockSodium.crypto_xof_shake256(any(), any(), any(), any()))
            .thenAnswer((i) {
              fillPointer(i.positionalArguments[0] as Pointer, output);
              return 0;
            });

        final result = sut(message: Uint8List(20), outLen: outLen);

        expect(result, output);

        verify(() => mockSodium.sodium_free(any())).called(1);
      });

      test('throws if crypto_xof_shake256 fails', () {
        when(() => mockSodium.crypto_xof_shake256(any(), any(), any(), any()))
            .thenReturn(1);

        expect(
          () => sut(message: Uint8List(20), outLen: outLen),
          throwsA(isA<SodiumException>()),
        );

        verify(() => mockSodium.sodium_free(any())).called(2);
      });
    });

    group('createConsumer', () {
      test('asserts if domain is invalid', () {
        expect(() => sut.createConsumer(domain: 0), throwsA(isA<RangeError>()));

        verifyNever(
          () => mockSodium.crypto_xof_shake256_init_with_domain(any(), any()),
        );
      });

      test('creates a consumer that is initialized with '
          'crypto_xof_shake256_init', () {
        when(() => mockSodium.crypto_xof_shake256_init(any())).thenReturn(0);

        final result = sut.createConsumer();

        addTearDown(result.dispose);

        expect(result, isA<XofConsumerFFI<crypto_xof_shake256_state>>());

        verifyInOrder([
          () => mockSodium.crypto_xof_shake256_statebytes(),
          () => mockSodium.sodium_allocarray(stateBytes, 1),
          () => mockSodium.crypto_xof_shake256_init(any(that: isNot(nullptr))),
        ]);
        verifyNever(
          () => mockSodium.crypto_xof_shake256_init_with_domain(any(), any()),
        );
      });

      test('creates a consumer that is initialized with '
          'crypto_xof_shake256_init_with_domain', () {
        when(
          () => mockSodium.crypto_xof_shake256_init_with_domain(any(), any()),
        ).thenReturn(0);

        const domain = 0x42;

        final result = sut.createConsumer(domain: domain);

        addTearDown(result.dispose);

        expect(result, isA<XofConsumerFFI<crypto_xof_shake256_state>>());

        verifyInOrder([
          () => mockSodium.crypto_xof_shake256_statebytes(),
          () => mockSodium.sodium_allocarray(stateBytes, 1),
          () => mockSodium.crypto_xof_shake256_init_with_domain(
            any(that: isNot(nullptr)),
            domain,
          ),
        ]);
        verifyNever(() => mockSodium.crypto_xof_shake256_init(any()));
      });

      test('creates a consumer that uses crypto_xof_shake256_update and '
          'crypto_xof_shake256_squeeze', () {
        when(() => mockSodium.crypto_xof_shake256_init(any())).thenReturn(0);
        when(() => mockSodium.crypto_xof_shake256_update(any(), any(), any()))
            .thenReturn(0);

        final output = List.generate(outLen, (index) => index * 2);
        when(() => mockSodium.crypto_xof_shake256_squeeze(any(), any(), any()))
            .thenAnswer((i) {
              fillPointer(i.positionalArguments[1] as Pointer, output);
              return 0;
            });

        final message = List.generate(20, (index) => index * 3);

        // ignore: close_sinks for testing
        final consumer = sut.createConsumer();
        final Uint8List result;
        try {
          consumer.add(Uint8List.fromList(message));
          result = consumer.squeeze(outLen);
        } finally {
          consumer.dispose();
        }

        expect(result, output);

        verifyInOrder([
          () => mockSodium.crypto_xof_shake256_update(
            any(that: isNot(nullptr)),
            any(that: hasRawData<UnsignedChar>(message)),
            message.length,
          ),
          () => mockSodium.crypto_xof_shake256_squeeze(
            any(that: isNot(nullptr)),
            any(that: isNot(nullptr)),
            outLen,
          ),
        ]);
      });
    });
  });
}
