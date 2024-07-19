import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/js/api/helpers/sign/sign_consumer_js_mixin.dart';
import 'package:sodium/src/js/bindings/js_error.dart';

import 'package:test/test.dart';

import '../../../sodium_js_mock.dart';

@isTestGroup
void addStreamTests({
  required MockLibSodiumJS mockSodium,
  required num state,
  required SignConsumerJSMixin Function() createSut,
  void Function()? setUpVerify,
}) {
  group('add', () {
    late SignConsumerJSMixin sut;

    setUp(() {
      sut = createSut();
    });

    test('call crypto_sign_update on stream events', () {
      final message = List.generate(25, (index) => index * 3);

      sut.add(Uint8List.fromList(message));

      verify(
        () => mockSodium.crypto_sign_update(
          state.toJS,
          Uint8List.fromList(message).toJS,
        ),
      );
    });

    test('throws StateError when adding a stream after completition', () async {
      setUpVerify?.call();

      await sut.close();

      expect(
        () => sut.add(Uint8List(0)),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('addStream', () {
    late StreamConsumer<Uint8List> sut;

    setUp(() {
      sut = createSut();
    });

    test('call crypto_sign_update on stream events', () async {
      final message = List.generate(25, (index) => index * 3);

      await sut.addStream(Stream.value(Uint8List.fromList(message)));

      verify(
        () => mockSodium.crypto_sign_update(
          state.toJS,
          Uint8List.fromList(message).toJS,
        ),
      );
    });

    test('throws exception and cancels addStream on error', () async {
      when(() => mockSodium.crypto_sign_update(any(), any()))
          .thenThrow(JSError());

      final message = List.generate(25, (index) => index * 3);

      await expectLater(
        () => sut.addStream(Stream.value(Uint8List.fromList(message))),
        throwsA(isA<SodiumException>()),
      );
    });

    test('throws StateError when adding a stream after completition', () async {
      setUpVerify?.call();

      await sut.close();

      expect(
        () => sut.addStream(const Stream.empty()),
        throwsA(isA<StateError>()),
      );
    });
  });
}
