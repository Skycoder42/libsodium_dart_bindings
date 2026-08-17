// ignore_for_file: unnecessary_lambdas for mocking

@TestOn('js')
library;

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/js/api/helpers/xof/xof_consumer_js.dart';
import 'package:sodium/src/js/bindings/js_error.dart';
import 'package:sodium/src/js/bindings/sodium.js.dart';
import 'package:test/test.dart';

import '../../../sodium_js_mock.dart';

void main() {
  const state = 234;
  const domain = 0x42;
  const outLen = 10;

  final mockSodium = MockLibSodiumJS();

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    reset(mockSodium);
  });

  XofConsumerJS<XofShake128State> createSut() =>
      XofConsumerJS<XofShake128State>(
        sodium: mockSodium.asLibSodiumJS,
        xofInit: mockSodium.crypto_xof_shake128_init,
        xofUpdate: mockSodium.crypto_xof_shake128_update,
        xofSqueeze: mockSodium.crypto_xof_shake128_squeeze,
      );

  XofConsumerJS<XofShake128State> createDomainSut() =>
      XofConsumerJS<XofShake128State>.domain(
        sodium: mockSodium.asLibSodiumJS,
        xofInit: mockSodium.crypto_xof_shake128_init_with_domain,
        xofUpdate: mockSodium.crypto_xof_shake128_update,
        xofSqueeze: mockSodium.crypto_xof_shake128_squeeze,
        domain: domain,
      );

  group('constructor', () {
    test('initializes the xof state', () {
      when(() => mockSodium.crypto_xof_shake128_init()).thenReturn(state.toJS);

      // ignore: close_sinks for testing
      final sut = createSut();
      addTearDown(sut.dispose);

      verify(() => mockSodium.crypto_xof_shake128_init());
      verifyNever(() => mockSodium.crypto_xof_shake128_init_with_domain(any()));
    });

    test('initializes the xof state with the given domain', () {
      when(() => mockSodium.crypto_xof_shake128_init_with_domain(any()))
          .thenReturn(state.toJS);

      // ignore: close_sinks for testing
      final sut = createDomainSut();
      addTearDown(sut.dispose);

      verify(() => mockSodium.crypto_xof_shake128_init_with_domain(domain));
      verifyNever(() => mockSodium.crypto_xof_shake128_init());
    });

    test('throws SodiumException if the initialization fails', () {
      when(() => mockSodium.crypto_xof_shake128_init()).thenThrow(JSError());

      expect(createSut, throwsA(isA<SodiumException>()));
    });

    test('throws SodiumException if the domain initialization fails', () {
      when(() => mockSodium.crypto_xof_shake128_init_with_domain(any()))
          .thenThrow(JSError());

      expect(createDomainSut, throwsA(isA<SodiumException>()));
    });
  });

  group('members', () {
    late XofConsumerJS<XofShake128State> sut;

    setUp(() {
      when(() => mockSodium.crypto_xof_shake128_init()).thenReturn(state.toJS);

      sut = createSut();

      clearInteractions(mockSodium);
    });

    group('add', () {
      test('calls crypto_xof_shake128_update with the given data', () {
        final message = List.generate(20, (index) => index * 3);

        sut.add(Uint8List.fromList(message));

        verify(
          () => mockSodium.crypto_xof_shake128_update(
            state.toJS,
            Uint8List.fromList(message).toJS,
          ),
        );
      });

      test('throws if crypto_xof_shake128_update fails', () {
        when(() => mockSodium.crypto_xof_shake128_update(any(), any()))
            .thenThrow(JSError());

        expect(() => sut.add(Uint8List(20)), throwsA(isA<SodiumException>()));
      });

      test('throws a StateError if the consumer has been closed', () async {
        await sut.close();

        expect(() => sut.add(Uint8List(0)), throwsA(isA<StateError>()));

        verifyNever(() => mockSodium.crypto_xof_shake128_update(any(), any()));
      });

      test('throws a StateError if the consumer has been squeezed', () {
        when(() => mockSodium.crypto_xof_shake128_squeeze(any(), any()))
            .thenReturn(Uint8List(0).toJS);

        sut.squeeze(outLen);

        expect(() => sut.add(Uint8List(0)), throwsA(isA<StateError>()));

        verifyNever(() => mockSodium.crypto_xof_shake128_update(any(), any()));
      });

      test('throws a StateError if the consumer has been disposed', () {
        sut.dispose();

        expect(() => sut.add(Uint8List(0)), throwsA(isA<StateError>()));
      });
    });

    group('addStream', () {
      test('calls crypto_xof_shake128_update for every stream event', () async {
        final message1 = List.generate(20, (index) => index * 3);
        final message2 = List.generate(10, (index) => index + 7);

        await sut.addStream(
          Stream.fromIterable([
            Uint8List.fromList(message1),
            Uint8List.fromList(message2),
          ]),
        );

        verifyInOrder([
          () => mockSodium.crypto_xof_shake128_update(
            state.toJS,
            Uint8List.fromList(message1).toJS,
          ),
          () => mockSodium.crypto_xof_shake128_update(
            state.toJS,
            Uint8List.fromList(message2).toJS,
          ),
        ]);
      });

      test('throws exception and cancels addStream on error', () async {
        when(() => mockSodium.crypto_xof_shake128_update(any(), any()))
            .thenThrow(JSError());

        final message = List.generate(20, (index) => index * 3);

        await expectLater(
          () => sut.addStream(Stream.value(Uint8List.fromList(message))),
          throwsA(isA<SodiumException>()),
        );
      });

      test('throws a StateError if the consumer has been closed', () async {
        await sut.close();

        expect(
          () => sut.addStream(const Stream.empty()),
          throwsA(isA<StateError>()),
        );
      });

      test('throws a StateError if the consumer has been squeezed', () {
        when(() => mockSodium.crypto_xof_shake128_squeeze(any(), any()))
            .thenReturn(Uint8List(0).toJS);

        sut.squeeze(outLen);

        expect(
          () => sut.addStream(const Stream.empty()),
          throwsA(isA<StateError>()),
        );
      });

      test('throws a StateError if the consumer has been disposed', () {
        sut.dispose();

        expect(
          () => sut.addStream(const Stream.empty()),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('close', () {
      test('does not invoke any native function', () async {
        await sut.close();

        verifyZeroInteractions(mockSodium);
      });

      test('prevents any further data from being absorbed', () async {
        await sut.close();

        expect(() => sut.add(Uint8List(0)), throwsA(isA<StateError>()));
      });

      test('can be called multiple times', () async {
        await sut.close();
        await sut.close();

        verifyZeroInteractions(mockSodium);
      });

      test('throws a StateError if the consumer has been disposed', () {
        sut.dispose();

        expect(sut.close, throwsA(isA<StateError>()));
      });
    });

    group('squeeze', () {
      test('asserts if outLen is invalid', () {
        expect(() => sut.squeeze(0), throwsA(isA<RangeError>()));

        verifyNever(() => mockSodium.crypto_xof_shake128_squeeze(any(), any()));
      });

      test('calls crypto_xof_shake128_squeeze with correct arguments', () {
        when(() => mockSodium.crypto_xof_shake128_squeeze(any(), any()))
            .thenReturn(Uint8List(0).toJS);

        sut.squeeze(outLen);

        verify(
          () => mockSodium.crypto_xof_shake128_squeeze(state.toJS, outLen),
        );
      });

      test('returns the squeezed output', () {
        final output = List.generate(outLen, (index) => 100 - index);

        when(() => mockSodium.crypto_xof_shake128_squeeze(any(), any()))
            .thenReturn(Uint8List.fromList(output).toJS);

        final result = sut.squeeze(outLen);

        expect(result, output);
      });

      test('throws if crypto_xof_shake128_squeeze fails', () {
        when(() => mockSodium.crypto_xof_shake128_squeeze(any(), any()))
            .thenThrow(JSError());

        expect(() => sut.squeeze(outLen), throwsA(isA<SodiumException>()));
      });

      test('can be squeezed multiple times', () {
        when(() => mockSodium.crypto_xof_shake128_squeeze(any(), any()))
            .thenReturn(Uint8List(0).toJS);

        sut
          ..squeeze(outLen)
          ..squeeze(outLen);

        verify(() => mockSodium.crypto_xof_shake128_squeeze(state.toJS, outLen))
            .called(2);
      });

      test('can be squeezed after the consumer has been closed', () async {
        when(() => mockSodium.crypto_xof_shake128_squeeze(any(), any()))
            .thenReturn(Uint8List(0).toJS);

        await sut.close();

        expect(() => sut.squeeze(outLen), returnsNormally);
      });

      test('throws a StateError if the consumer has been disposed', () {
        sut.dispose();

        expect(() => sut.squeeze(outLen), throwsA(isA<StateError>()));
      });
    });

    group('dispose', () {
      test('frees the xof state', () {
        sut.dispose();

        verify(() => mockSodium.free(state.toJS));
      });

      test('can be called multiple times without freeing twice', () {
        sut
          ..dispose()
          ..dispose();

        verify(() => mockSodium.free(state.toJS)).called(1);
      });

      test('throws if free fails', () {
        when(() => mockSodium.free(any())).thenThrow(JSError());

        expect(sut.dispose, throwsA(isA<SodiumException>()));
      });

      test('invalidates the consumer', () {
        sut.dispose();

        expect(() => sut.add(Uint8List(0)), throwsA(isA<StateError>()));
        expect(
          () => sut.addStream(const Stream.empty()),
          throwsA(isA<StateError>()),
        );
        expect(sut.close, throwsA(isA<StateError>()));
        expect(() => sut.squeeze(outLen), throwsA(isA<StateError>()));
      });
    });
  });
}
