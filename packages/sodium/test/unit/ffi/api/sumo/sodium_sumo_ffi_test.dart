// ignore_for_file: unnecessary_lambdas for mocking

@TestOn('dart-vm')
library;

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/ffi/api/sumo/crypto_sumo_ffi.dart';
import 'package:sodium/src/ffi/api/sumo/sodium_sumo_ffi.dart';
import 'package:sodium/src/ffi/bindings/libsodium.ffi.wrapper.dart';
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

    sut = SodiumSumoFFI(mockSodium);
  });

  test('crypto returns CryptoSumoFFI instance', () {
    expect(
      sut.crypto,
      isA<CryptoSumoFFI>().having((p) => p.sodium, 'sodium', mockSodium),
    );
  });
}
