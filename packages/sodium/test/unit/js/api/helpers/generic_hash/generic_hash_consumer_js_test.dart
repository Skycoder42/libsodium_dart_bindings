import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/js/api/helpers/generic_hash/generic_hash_consumer_js.dart';
import 'package:sodium/src/js/bindings/js_error.dart';
import 'package:sodium/src/js/bindings/sodium.js.dart';
import 'package:test/test.dart';

import '../../../../../secure_key_fake.dart';

class MockSodiumJS extends Mock implements LibSodiumJS {}

void main() {
  const state = 234;
  const outLen = 42;

  final mockSodium = MockSodiumJS();

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
      ).thenReturn(state);

      GenericHashConsumerJS(
        sodium: mockSodium,
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
      ).thenReturn(state);

      final key = List.generate(15, (index) => index + 5);

      GenericHashConsumerJS(
        sodium: mockSodium,
        outLen: outLen,
        key: SecureKeyFake(key),
      );

      verify(
        () => mockSodium.crypto_generichash_init(
          Uint8List.fromList(key),
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
      ).thenThrow(JsError());

      expect(
        () => GenericHashConsumerJS(
          sodium: mockSodium,
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
      ).thenReturn(state);

      sut = GenericHashConsumerJS(
        sodium: mockSodium,
        outLen: outLen,
      );

      clearInteractions(mockSodium);
    });

    group('addStream', () {
      test('calls crypto_generichash_update on stream events', () async {
        final message = List.generate(25, (index) => index * 3);

        await sut.addStream(Stream.value(Uint8List.fromList(message)));

        verify(
          () => mockSodium.crypto_generichash_update(
            state,
            Uint8List.fromList(message),
          ),
        );
      });

      test('throws exception and cancels addStream on error', () async {
        when(() => mockSodium.crypto_generichash_update(any(), any()))
            .thenThrow(JsError());

        final message = List.generate(25, (index) => index * 3);

        await expectLater(
          () => sut.addStream(Stream.value(Uint8List.fromList(message))),
          throwsA(isA<SodiumException>()),
        );
      });

      test('throws StateError when adding a stream after completition',
          () async {
        when(() => mockSodium.crypto_generichash_final(any(), any()))
            .thenReturn(Uint8List(0));

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
        ).thenReturn(Uint8List(0));

        await sut.close();

        verify(
          () => mockSodium.crypto_generichash_final(
            state,
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
        ).thenReturn(Uint8List.fromList(hash));

        final result = await sut.close();

        expect(result, Uint8List.fromList(hash));
      });

      test('throws exception if hashing fails', () async {
        when(
          () => mockSodium.crypto_generichash_final(
            any(),
            any(),
          ),
        ).thenThrow(JsError());

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
        ).thenReturn(Uint8List(0));

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
        ).thenReturn(Uint8List(0));

        final hash = sut.hash;
        final closed = sut.close();

        expect(hash, closed);
        expect(await hash, await closed);
      });
    });
  });
}
