// ignore_for_file: unnecessary_lambdas for mocking

@TestOn('dart-vm')
library;

import 'dart:ffi';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/secure_key.dart';
import 'package:sodium/src/ffi/api/sumo/crypto_sumo_ffi.dart';
import 'package:sodium/src/ffi/api/sumo/sodium_sumo_ffi.dart';
import 'package:sodium/src/ffi/bindings/libsodium.ffi.dart';
import 'package:test/test.dart';

import '../../pointer_test_helpers.dart';

class MockSodiumFFI extends Mock implements LibSodiumFFI {}

void main() {
  final mockSodium = MockSodiumFFI();

  late SodiumSumoFFI sut;

  setUpAll(() {
    registerPointers();
  });

  setUp(() {
    reset(mockSodium);

    sut = SodiumSumoFFI(mockSodium, () {
      registerPointers();
      final sodium = MockSodiumFFI();
      mockAllocArray(sodium, delayedFree: false);
      return sodium;
    });
  });

  test('fromFactory returns instance created by the factory', () async {
    final sut = await SodiumSumoFFI.fromFactory(() => MockSodiumFFI());
    expect(sut.sodium, isNot(same(mockSodium)));
  });

  test('crypto returns CryptoSumoFFI instance', () {
    expect(
      sut.crypto,
      isA<CryptoSumoFFI>().having((p) => p.sodium, 'sodium', mockSodium),
    );
  });

  group('runIsolated', () {
    test('invokes the given callback with a sodium sumo instance', () async {
      final isSodiumSumo = await sut.runIsolated(
        (sodium, secureKeys, keyPairs) => sodium is SodiumSumoFFI,
      );

      expect(isSodiumSumo, isTrue);
    });
  });

  test(
    'isolateFactory returns a factory that '
    'can create a sodium sumo instance with a different ffi reference',
    () async {
      when(() => mockSodium.sodium_library_version_major()).thenReturn(1);
      when(() => mockSodium.sodium_library_version_minor()).thenReturn(2);
      when(() => mockSodium.sodium_version_string()).thenReturn(nullptr);

      final factory = sut.isolateFactory;

      final newSodium = await factory();

      expect(
        newSodium,
        isA<SodiumSumoFFI>().having(
          (m) => m.sodium,
          'sodium',
          isNot(same(mockSodium)),
        ),
      );
      expect(
        newSodium.secureAlloc(10),
        isA<SecureKey>().having((m) => m.length, 'length', 10),
      );
    },
  );
}
