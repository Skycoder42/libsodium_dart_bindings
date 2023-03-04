// ignore_for_file: unnecessary_lambdas

@TestOn('dart-vm')
library sodium_ffi_init_test;

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/ffi/api/sodium_ffi.dart';
import 'package:sodium/src/ffi/bindings/libsodium.ffi.dart';
import 'package:sodium/src/ffi/sodium_sumo_ffi_init.dart';
import 'package:test/test.dart';

class MockSodiumFFI extends Mock implements LibSodiumFFI {}

void main() {
  final mockSodium = MockSodiumFFI();

  setUp(() {
    reset(mockSodium);
  });

  test('calls sodium_init', () async {
    when(() => mockSodium.sodium_init()).thenReturn(0);

    await SodiumSumoInit.initFromSodiumFFI(mockSodium);

    verify(() => mockSodium.sodium_init());
  });

  test('throws if sodium_init fails', () {
    when(() => mockSodium.sodium_init()).thenReturn(-1);

    expect(
      () async => SodiumSumoInit.initFromSodiumFFI(mockSodium),
      throwsA(isA<SodiumException>()),
    );
  });

  test('resturns SodiumFFI instance', () async {
    when(() => mockSodium.sodium_init()).thenReturn(0);

    final sodium = await SodiumSumoInit.initFromSodiumFFI(mockSodium);
    expect(
      sodium,
      isA<SodiumFFI>().having(
        (s) => s.sodium,
        'sodium',
        mockSodium,
      ),
    );
  });
}
