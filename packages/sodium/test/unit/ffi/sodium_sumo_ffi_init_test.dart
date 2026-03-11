// ignore_for_file: unnecessary_lambdas for mocking

@TestOn('dart-vm')
library;

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/ffi/api/sumo/sodium_sumo_ffi.dart';
import 'package:sodium/src/ffi/bindings/libsodium.ffi.wrapper.dart';
import 'package:sodium/src/ffi/sodium_sumo_ffi_init.dart';
import 'package:test/test.dart';

class MockSodiumFFI extends Mock implements LibSodiumFFI {}

void main() {
  final mockSodium = MockSodiumFFI();

  setUp(() {
    reset(mockSodium);
  });

  test('calls sodium_init', () {
    when(() => mockSodium.sodium_init()).thenReturn(0);

    SodiumSumoInit.initFromFFI(mockSodium);

    verify(() => mockSodium.sodium_init());
  });

  test('throws if sodium_init fails', () {
    when(() => mockSodium.sodium_init()).thenReturn(-1);

    expect(
      () => SodiumSumoInit.initFromFFI(mockSodium),
      throwsA(isA<SodiumException>()),
    );
  });

  test('returns SodiumSumoFFI instance', () {
    when(() => mockSodium.sodium_init()).thenReturn(0);

    final sodium = SodiumSumoInit.initFromFFI(mockSodium);
    expect(
      sodium,
      isA<SodiumSumoFFI>().having((s) => s.sodium, 'sodium', mockSodium),
    );
  });
}
