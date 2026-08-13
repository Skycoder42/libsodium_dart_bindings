// ignore_for_file: unnecessary_lambdas for mocking

@TestOn('dart-vm')
library;

import 'dart:ffi';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/ffi/api/helpers/xof/xof_consumer_ffi.dart';
import 'package:sodium/src/ffi/bindings/libsodium.ffi.dart'
    show crypto_xof_shake128_state;
import 'package:sodium/src/ffi/bindings/libsodium.ffi.wrapper.dart';
import 'package:test/test.dart';

import '../../../pointer_test_helpers.dart';

class MockSodiumFFI extends Mock implements LibSodiumFFI {}

void main() {
  const stateBytes = 5;
  const domain = 0x42;
  const outLen = 10;

  final mockSodium = MockSodiumFFI();

  setUpAll(() {
    registerPointers();
  });

  setUp(() {
    reset(mockSodium);

    mockAllocArray(mockSodium);
  });

  XofConsumerFFI<crypto_xof_shake128_state> createSut() =>
      XofConsumerFFI<crypto_xof_shake128_state>(
        sodium: mockSodium,
        stateBytes: stateBytes,
        xofInit: mockSodium.crypto_xof_shake128_init,
        xofUpdate: mockSodium.crypto_xof_shake128_update,
        xofSqueeze: mockSodium.crypto_xof_shake128_squeeze,
      );

  XofConsumerFFI<crypto_xof_shake128_state> createDomainSut() =>
      XofConsumerFFI<crypto_xof_shake128_state>.domain(
        sodium: mockSodium,
        stateBytes: stateBytes,
        xofInit: mockSodium.crypto_xof_shake128_init_with_domain,
        xofUpdate: mockSodium.crypto_xof_shake128_update,
        xofSqueeze: mockSodium.crypto_xof_shake128_squeeze,
        domain: domain,
      );

  group('constructor', () {
    test('initializes the xof state', () {
      late Pointer state;
      when(
        () => mockSodium.crypto_xof_shake128_init(any()),
      ).thenCapture(0, (p) => state = p);

      createSut();

      verifyInOrder([
        () => mockSodium.sodium_allocarray(stateBytes, 1),
        () => mockSodium.sodium_memzero(any(that: isNot(nullptr)), stateBytes),
        () => mockSodium.crypto_xof_shake128_init(
          any(that: hasAddress(state.address)),
        ),
        () => mockSodium.sodium_mprotect_noaccess(
          any(that: hasAddress(state.address)),
        ),
      ]);
      verifyNever(() => mockSodium.sodium_free(any()));
    });

    test('initializes the xof state with the given domain', () {
      late Pointer state;
      when(
        () => mockSodium.crypto_xof_shake128_init_with_domain(any(), any()),
      ).thenCapture(0, (p) => state = p);

      createDomainSut();

      verifyInOrder([
        () => mockSodium.sodium_allocarray(stateBytes, 1),
        () => mockSodium.sodium_memzero(any(that: isNot(nullptr)), stateBytes),
        () => mockSodium.crypto_xof_shake128_init_with_domain(
          any(that: hasAddress(state.address)),
          domain,
        ),
        () => mockSodium.sodium_mprotect_noaccess(
          any(that: hasAddress(state.address)),
        ),
      ]);
      verifyNever(() => mockSodium.crypto_xof_shake128_init(any()));
      verifyNever(() => mockSodium.sodium_free(any()));
    });

    test('disposes the state if the initialization fails', () {
      when(() => mockSodium.crypto_xof_shake128_init(any())).thenReturn(1);

      expect(createSut, throwsA(isA<SodiumException>()));

      verify(() => mockSodium.sodium_free(any(that: isNot(nullptr)))).called(1);
    });

    test('disposes the state if the domain initialization fails', () {
      when(
        () => mockSodium.crypto_xof_shake128_init_with_domain(any(), any()),
      ).thenReturn(1);

      expect(createDomainSut, throwsA(isA<SodiumException>()));

      verify(() => mockSodium.sodium_free(any(that: isNot(nullptr)))).called(1);
    });
  });

  group('members', () {
    late XofConsumerFFI<crypto_xof_shake128_state> sut;

    setUp(() {
      when(() => mockSodium.crypto_xof_shake128_init(any())).thenReturn(0);

      sut = createSut();

      clearInteractions(mockSodium);
    });

    group('add', () {
      test('calls crypto_xof_shake128_update with the given data', () {
        late Pointer state;
        when(
          () => mockSodium.crypto_xof_shake128_update(any(), any(), any()),
        ).thenCapture(0, (p) => state = p);

        final message = List.generate(20, (index) => index * 3);

        sut.add(Uint8List.fromList(message));

        verifyInOrder([
          () => mockSodium.sodium_mprotect_readonly(
            any(that: hasRawData(message)),
          ),
          () => mockSodium.sodium_mprotect_readwrite(
            any(that: hasAddress(state.address)),
          ),
          () => mockSodium.crypto_xof_shake128_update(
            any(that: hasAddress(state.address)),
            any(that: hasRawData<UnsignedChar>(message)),
            message.length,
          ),
          () => mockSodium.sodium_mprotect_noaccess(
            any(that: hasAddress(state.address)),
          ),
          () => mockSodium.sodium_free(any(that: hasRawData(message))),
        ]);
      });

      test(
        'throws and frees the message if crypto_xof_shake128_update fails',
        () {
          when(
            () => mockSodium.crypto_xof_shake128_update(any(), any(), any()),
          ).thenReturn(1);

          expect(() => sut.add(Uint8List(20)), throwsA(isA<SodiumException>()));

          verify(() => mockSodium.sodium_free(any())).called(1);
        },
      );

      test('restores the memory protection of the state if update fails', () {
        late Pointer state;
        when(
          () => mockSodium.crypto_xof_shake128_update(any(), any(), any()),
        ).thenCapture(0, (p) => state = p, returning: 1);

        expect(() => sut.add(Uint8List(20)), throwsA(isA<SodiumException>()));

        verify(
          () => mockSodium.sodium_mprotect_noaccess(
            any(that: hasAddress(state.address)),
          ),
        ).called(1);
      });

      test('throws a StateError if the consumer has been closed', () async {
        await sut.close();

        expect(() => sut.add(Uint8List(0)), throwsA(isA<StateError>()));
      });

      test('throws a StateError if the consumer has been squeezed', () {
        when(
          () => mockSodium.crypto_xof_shake128_squeeze(any(), any(), any()),
        ).thenReturn(0);

        sut.squeeze(outLen);

        expect(() => sut.add(Uint8List(0)), throwsA(isA<StateError>()));
      });

      test('throws a StateError if the consumer has been disposed', () {
        sut.dispose();

        expect(() => sut.add(Uint8List(0)), throwsA(isA<StateError>()));
      });
    });

    group('addStream', () {
      test('calls crypto_xof_shake128_update for every stream event', () async {
        late Pointer state;
        when(
          () => mockSodium.crypto_xof_shake128_update(any(), any(), any()),
        ).thenCapture(0, (p) => state = p);

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
            any(that: hasAddress(state.address)),
            any(that: hasRawData<UnsignedChar>(message1)),
            message1.length,
          ),
          () => mockSodium.crypto_xof_shake128_update(
            any(that: hasAddress(state.address)),
            any(that: hasRawData<UnsignedChar>(message2)),
            message2.length,
          ),
        ]);
      });

      test('throws exception and cancels addStream on error', () async {
        when(
          () => mockSodium.crypto_xof_shake128_update(any(), any(), any()),
        ).thenReturn(1);

        final message = List.generate(20, (index) => index * 3);

        await expectLater(
          () => sut.addStream(Stream.value(Uint8List.fromList(message))),
          throwsA(isA<SodiumException>()),
        );

        verify(() => mockSodium.sodium_free(any(that: hasRawData(message))));
      });

      test('throws a StateError if the consumer has been closed', () async {
        await sut.close();

        expect(
          () => sut.addStream(const Stream.empty()),
          throwsA(isA<StateError>()),
        );
      });

      test('throws a StateError if the consumer has been squeezed', () {
        when(
          () => mockSodium.crypto_xof_shake128_squeeze(any(), any(), any()),
        ).thenReturn(0);

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
      test('does not free any memory', () async {
        await sut.close();

        verifyNever(() => mockSodium.sodium_free(any()));
      });

      test('prevents any further data from being absorbed', () async {
        await sut.close();

        expect(() => sut.add(Uint8List(0)), throwsA(isA<StateError>()));
      });

      test('can be called multiple times', () async {
        await sut.close();
        await sut.close();

        verifyNever(() => mockSodium.sodium_free(any()));
      });

      test('throws a StateError if the consumer has been disposed', () {
        sut.dispose();

        expect(() => sut.close(), throwsA(isA<StateError>()));
      });
    });

    group('squeeze', () {
      test('asserts if outLen is invalid', () {
        expect(() => sut.squeeze(0), throwsA(isA<RangeError>()));

        verifyNever(
          () => mockSodium.crypto_xof_shake128_squeeze(any(), any(), any()),
        );
      });

      test('calls crypto_xof_shake128_squeeze with correct arguments', () {
        late Pointer state;
        when(
          () => mockSodium.crypto_xof_shake128_squeeze(any(), any(), any()),
        ).thenCapture(0, (p) => state = p);

        sut.squeeze(outLen);

        verifyInOrder([
          () => mockSodium.sodium_allocarray(outLen, 1),
          () => mockSodium.sodium_mprotect_readwrite(
            any(that: hasAddress(state.address)),
          ),
          () => mockSodium.crypto_xof_shake128_squeeze(
            any(that: hasAddress(state.address)),
            any(that: isNot(nullptr)),
            outLen,
          ),
          () => mockSodium.sodium_mprotect_noaccess(
            any(that: hasAddress(state.address)),
          ),
        ]);
      });

      test('returns the squeezed output', () {
        final output = List.generate(outLen, (index) => 100 - index);

        when(
          () => mockSodium.crypto_xof_shake128_squeeze(any(), any(), any()),
        ).thenAnswer((i) {
          fillPointer(i.positionalArguments[1] as Pointer, output);
          return 0;
        });

        final result = sut.squeeze(outLen);

        expect(result, output);

        verifyNever(() => mockSodium.sodium_free(any()));
      });

      test('throws if crypto_xof_shake128_squeeze fails', () {
        when(
          () => mockSodium.crypto_xof_shake128_squeeze(any(), any(), any()),
        ).thenReturn(1);

        expect(() => sut.squeeze(outLen), throwsA(isA<SodiumException>()));

        verify(() => mockSodium.sodium_free(any())).called(1);
      });

      test('can be squeezed multiple times', () {
        when(
          () => mockSodium.crypto_xof_shake128_squeeze(any(), any(), any()),
        ).thenReturn(0);

        sut
          ..squeeze(outLen)
          ..squeeze(outLen);

        verify(
          () => mockSodium.crypto_xof_shake128_squeeze(any(), any(), outLen),
        ).called(2);
      });

      test('can be squeezed after the consumer has been closed', () async {
        when(
          () => mockSodium.crypto_xof_shake128_squeeze(any(), any(), any()),
        ).thenReturn(0);

        await sut.close();

        expect(() => sut.squeeze(outLen), returnsNormally);
      });

      test('throws a StateError if the consumer has been disposed', () {
        sut.dispose();

        expect(() => sut.squeeze(outLen), throwsA(isA<StateError>()));
      });
    });

    group('dispose', () {
      test('frees the state', () {
        sut.dispose();

        verify(
          () => mockSodium.sodium_free(any(that: isNot(nullptr))),
        ).called(1);
      });

      test('can be called multiple times', () {
        sut
          ..dispose()
          ..dispose();

        verify(() => mockSodium.sodium_free(any())).called(1);
      });
    });
  });
}
