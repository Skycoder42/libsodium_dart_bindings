// ignore_for_file: unnecessary_lambdas

@TestOn('dart-vm')
library sodium_sumo_ffi_test;

import 'package:mocktail/mocktail.dart';
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

    sut = SodiumSumoFFI(mockSodium, () => mockSodium);
  });

  test('fromFactory returns instance created by the factory', () async {
    final sut = await SodiumSumoFFI.fromFactory(() => MockSodiumFFI());
    expect(sut.sodium, isNot(same(mockSodium)));
  });

  test('crypto returns CryptoSumoFFI instance', () {
    expect(
      sut.crypto,
      isA<CryptoSumoFFI>().having(
        (p) => p.sodium,
        'sodium',
        mockSodium,
      ),
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
}
