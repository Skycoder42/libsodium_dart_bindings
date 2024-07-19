@TestOn('js')
library generic_hash_consumer_js_test;

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/js/api/helpers/generic_hash/generic_hash_consumer_js.dart';
import 'package:sodium/src/js/bindings/js_error.dart';
import 'package:test/test.dart';

import '../../../../../secure_key_fake.dart';

import '../../../sodium_js_mock.dart';

void main() {
  const state = 234;
  const outLen = 42;

  final mockSodium = MockLibSodiumJS();

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    reset(mockSodium);

    when(() => mockSodium.crypto_generichash_KEYBYTES).thenReturn(15);
  });

  group('constructor', () {
    test('initializes hash state', () {
      when(
        () => mockSodium.crypto_generichash_init(
          any(),
          any(),
        ),
      ).thenReturn(state.toJS);

      GenericHashConsumerJS(
        sodium: mockSodium.asLibSodiumJS,
        outLen: outLen,
      );

      verify(
        () => mockSodium.crypto_generichash_init(
          null,
          outLen,
        ),
      );
    });

    test('initializes hash state with key', () {
      when(
        () => mockSodium.crypto_generichash_init(
          any(),
          any(),
        ),
      ).thenReturn(state.toJS);

      final key = List.generate(15, (index) => index + 5);

      GenericHashConsumerJS(
        sodium: mockSodium.asLibSodiumJS,
        outLen: outLen,
        key: SecureKeyFake(key),
      );

      verify(
        () => mockSodium.crypto_generichash_init(
          Uint8List.fromList(key).toJS,
          outLen,
        ),
      );
    });

    test('throws SodiumException on error', () {
      when(
        () => mockSodium.crypto_generichash_init(
          any(),
          any(),
        ),
      ).thenThrow(JSError());

      expect(
        () => GenericHashConsumerJS(
          sodium: mockSodium.asLibSodiumJS,
          outLen: outLen,
        ),
        throwsA(isA<SodiumException>()),
      );
    });
  });

  group('members', () {
    late GenericHashConsumerJS sut;

    setUp(() {
      when(
        () => mockSodium.crypto_generichash_init(
          any(),
          any(),
        ),
      ).thenReturn(state.toJS);

      sut = GenericHashConsumerJS(
        sodium: mockSodium.asLibSodiumJS,
        outLen: outLen,
      );

      clearInteractions(mockSodium);
    });

    group('add', () {
      test('calls crypto_generichash_update with the given data', () {
        final message = List.generate(25, (index) => index * 3);

        sut.add(Uint8List.fromList(message));

        verify(
          () => mockSodium.crypto_generichash_update(
            state.toJS,
            Uint8List.fromList(message).toJS,
          ),
        );
      });

      test('throws StateError when adding data after completition', () async {
        when(() => mockSodium.crypto_generichash_final(any(), any()))
            .thenReturn(Uint8List(0).toJS);

        await sut.close();

        expect(
          () => sut.add(Uint8List(0)),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('addStream', () {
      test('calls crypto_generichash_update on stream events', () async {
        final message = List.generate(25, (index) => index * 3);

        await sut.addStream(Stream.value(Uint8List.fromList(message)));

        verify(
          () => mockSodium.crypto_generichash_update(
            state.toJS,
            Uint8List.fromList(message).toJS,
          ),
        );
      });

      test('throws exception and cancels addStream on error', () async {
        when(() => mockSodium.crypto_generichash_update(any(), any()))
            .thenThrow(JSError());

        final message = List.generate(25, (index) => index * 3);

        await expectLater(
          () => sut.addStream(Stream.value(Uint8List.fromList(message))),
          throwsA(isA<SodiumException>()),
        );
      });

      test('throws StateError when adding a stream after completition',
          () async {
        when(() => mockSodium.crypto_generichash_final(any(), any()))
            .thenReturn(Uint8List(0).toJS);

        await sut.close();

        expect(
          () => sut.addStream(const Stream.empty()),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('close', () {
      test('calls crypto_generichash_final with correct arguments', () async {
        when(
          () => mockSodium.crypto_generichash_final(
            any(),
            any(),
          ),
        ).thenReturn(Uint8List(0).toJS);

        await sut.close();

        verify(
          () => mockSodium.crypto_generichash_final(
            state.toJS,
            outLen,
          ),
        );
      });

      test('returns hash on success', () async {
        final hash = List.generate(outLen, (index) => index * 12);

        when(
          () => mockSodium.crypto_generichash_final(
            any(),
            any(),
          ),
        ).thenReturn(Uint8List.fromList(hash).toJS);

        final result = await sut.close();

        expect(result, Uint8List.fromList(hash));
      });

      test('throws exception if hashing fails', () async {
        when(
          () => mockSodium.crypto_generichash_final(
            any(),
            any(),
          ),
        ).thenThrow(JSError());

        await expectLater(
          () => sut.close(),
          throwsA(isA<SodiumException>()),
        );
      });

      test('throws state error if close is called a second time', () async {
        when(
          () => mockSodium.crypto_generichash_final(
            any(),
            any(),
          ),
        ).thenReturn(Uint8List(0).toJS);

        await sut.close();

        await expectLater(
          () => sut.close(),
          throwsA(isA<StateError>()),
        );
      });

      test('returns same future as hash', () async {
        when(
          () => mockSodium.crypto_generichash_final(
            any(),
            any(),
          ),
        ).thenReturn(Uint8List(0).toJS);

        final hash = sut.hash;
        final closed = sut.close();

        expect(hash, closed);
        expect(await hash, await closed);
      });
    });
  });
}
