@OnPlatform(<String, dynamic>{'!dart-vm': Skip('Requires dart:ffi')})

import 'dart:async';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/ffi/bindings/libsodium.ffi.dart';
import 'package:test/test.dart';

import '../../../pointer_test_helpers.dart';

@isTestGroup
void initStateTests({
  required LibSodiumFFI mockSodium,
  required StreamConsumer<Uint8List> Function() createSut,
  void Function()? setUp,
}) {
  test('initializes sign state', () {
    setUp?.call();
    when(() => mockSodium.crypto_sign_init(any())).thenReturn(0);

    createSut();

    verifyInOrder([
      () => mockSodium.crypto_sign_statebytes(),
      () => mockSodium.sodium_allocarray(5, 1),
      () => mockSodium.sodium_memzero(any(that: isNot(nullptr)), 5),
      () => mockSodium.crypto_sign_init(any(that: isNot(nullptr))),
    ]);
  });

  test('disposes sign state on error', () {
    setUp?.call();
    when(() => mockSodium.crypto_sign_init(any())).thenReturn(1);

    expect(
      createSut,
      throwsA(isA<SodiumException>()),
    );

    verifyInOrder([
      () => mockSodium.crypto_sign_statebytes(),
      () => mockSodium.sodium_allocarray(5, 1),
      () => mockSodium.sodium_memzero(any(that: isNot(nullptr)), 5),
      () => mockSodium.crypto_sign_init(any(that: isNot(nullptr))),
      () => mockSodium.sodium_free(any(that: isNot(nullptr))),
    ]);
  });
}

@isTestGroup
void addStreamTests({
  required LibSodiumFFI mockSodium,
  required StreamConsumer<Uint8List> Function() createSut,
  void Function()? setUpVerify,
}) {
  assert(mockSodium is Mock);

  group('addStream', () {
    late StreamConsumer<Uint8List> sut;

    setUp(() {
      sut = createSut();
    });

    test('call crypto_sign_update on stream events', () async {
      when(() => mockSodium.crypto_sign_update(any(), any(), any()))
          .thenReturn(0);

      final message = List.generate(25, (index) => index * 3);

      await sut.addStream(Stream.value(Uint8List.fromList(message)));

      verifyInOrder([
        () => mockSodium.sodium_mprotect_readonly(
              any(that: hasRawData(message)),
            ),
        () => mockSodium.crypto_sign_update(
              any(that: isNot(nullptr)),
              any(that: hasRawData<Uint8>(message)),
              message.length,
            ),
        () => mockSodium.sodium_free(
              any(that: hasRawData(message)),
            ),
      ]);
    });

    test('throws exception and cancels addStream on error', () async {
      when(() => mockSodium.crypto_sign_update(any(), any(), any()))
          .thenReturn(1);

      final message = List.generate(25, (index) => index * 3);

      await expectLater(
        () => sut.addStream(Stream.value(Uint8List.fromList(message))),
        throwsA(isA<SodiumException>()),
      );

      verify(
        () => mockSodium.sodium_free(
          any(that: hasRawData(message)),
        ),
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
