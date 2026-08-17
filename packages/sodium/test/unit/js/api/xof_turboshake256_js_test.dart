// ignore_for_file: unnecessary_lambdas for mocking

@TestOn('js')
library;

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/js/api/helpers/xof/xof_consumer_js.dart';
import 'package:sodium/src/js/api/xof_turboshake256_js.dart';
import 'package:sodium/src/js/bindings/js_error.dart';
import 'package:sodium/src/js/bindings/sodium.js.dart';
import 'package:test/test.dart';

import '../../../test_constants_mapping.dart';
import '../sodium_js_mock.dart';

void main() {
  const state = 234;
  const outLen = 10;

  final mockSodium = MockLibSodiumJS();

  late XofTurboshake256JS sut;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    reset(mockSodium);

    sut = XofTurboshake256JS(mockSodium.asLibSodiumJS);
  });

  testConstantsMapping([
    (
      () => mockSodium.crypto_xof_turboshake256_BLOCKBYTES,
      () => sut.blockBytes,
      'blockBytes',
    ),
    (
      () => mockSodium.crypto_xof_turboshake256_STATEBYTES,
      () => sut.stateBytes,
      'stateBytes',
    ),
  ]);

  // libsodium.js does not export crypto_xof_turboshake256_DOMAIN_STANDARD, so
  // the value is hardcoded in the implementation instead of being read from the
  // bindings.
  test('provides a hardcoded domainStandard', () {
    expect(sut.domainStandard, 0x1F);

    verifyZeroInteractions(mockSodium);
  });

  group('methods', () {
    setUp(() {
      when(() => mockSodium.crypto_xof_turboshake256_BLOCKBYTES).thenReturn(5);
      when(() => mockSodium.crypto_xof_turboshake256_STATEBYTES).thenReturn(5);
    });

    group('call', () {
      test('asserts if outLen is invalid', () {
        expect(
          () => sut(message: Uint8List(20), outLen: 0),
          throwsA(isA<RangeError>()),
        );

        verifyNever(() => mockSodium.crypto_xof_turboshake256(any(), any()));
      });

      test('calls crypto_xof_turboshake256 with correct arguments', () {
        when(() => mockSodium.crypto_xof_turboshake256(any(), any()))
            .thenReturn(Uint8List(0).toJS);

        final message = List.generate(20, (index) => index * 3);

        sut(message: Uint8List.fromList(message), outLen: outLen);

        verify(
          () => mockSodium.crypto_xof_turboshake256(
            outLen,
            Uint8List.fromList(message).toJS,
          ),
        );
      });

      test('returns the generated output', () {
        final output = List.generate(outLen, (index) => 100 - index);

        when(() => mockSodium.crypto_xof_turboshake256(any(), any()))
            .thenReturn(Uint8List.fromList(output).toJS);

        final result = sut(message: Uint8List(20), outLen: outLen);

        expect(result, output);
      });

      test('throws exception on failure', () {
        when(() => mockSodium.crypto_xof_turboshake256(any(), any()))
            .thenThrow(JSError());

        expect(
          () => sut(message: Uint8List(20), outLen: outLen),
          throwsA(isA<SodiumException>()),
        );
      });
    });

    group('createConsumer', () {
      test('asserts if domain is invalid', () {
        expect(() => sut.createConsumer(domain: 0), throwsA(isA<RangeError>()));

        verifyNever(
          () => mockSodium.crypto_xof_turboshake256_init_with_domain(any()),
        );
      });

      test('creates a consumer that is initialized with '
          'crypto_xof_turboshake256_init', () {
        when(() => mockSodium.crypto_xof_turboshake256_init())
            .thenReturn(state.toJS);

        final result = sut.createConsumer();

        addTearDown(result.dispose);

        expect(result, isA<XofConsumerJS<XofTurboshake256State>>());

        verify(() => mockSodium.crypto_xof_turboshake256_init());
        verifyNever(
          () => mockSodium.crypto_xof_turboshake256_init_with_domain(any()),
        );
      });

      test('creates a consumer that is initialized with '
          'crypto_xof_turboshake256_init_with_domain', () {
        when(() => mockSodium.crypto_xof_turboshake256_init_with_domain(any()))
            .thenReturn(state.toJS);

        const domain = 0x42;

        final result = sut.createConsumer(domain: domain);

        addTearDown(result.dispose);

        expect(result, isA<XofConsumerJS<XofTurboshake256State>>());

        verify(
          () => mockSodium.crypto_xof_turboshake256_init_with_domain(domain),
        );
        verifyNever(() => mockSodium.crypto_xof_turboshake256_init());
      });

      test('creates a consumer that uses crypto_xof_turboshake256_update and '
          'crypto_xof_turboshake256_squeeze', () {
        when(() => mockSodium.crypto_xof_turboshake256_init())
            .thenReturn(state.toJS);

        final output = List.generate(outLen, (index) => index * 2);
        when(() => mockSodium.crypto_xof_turboshake256_squeeze(any(), any()))
            .thenReturn(Uint8List.fromList(output).toJS);

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
          () => mockSodium.crypto_xof_turboshake256_update(
            state.toJS,
            Uint8List.fromList(message).toJS,
          ),
          () => mockSodium.crypto_xof_turboshake256_squeeze(state.toJS, outLen),
        ]);
      });
    });
  });
}
