// ignore_for_file: unnecessary_lambdas for mocking

@TestOn('dart-vm')
library;

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/ffi/api/sodium_ffi.dart';
import 'package:sodium/src/ffi/bindings/libsodium.ffi.wrapper.dart';
import 'package:sodium/src/ffi/sodium_ffi_init.dart';
import 'package:test/test.dart';

class MockSodiumFFI extends Mock implements LibSodiumFFI {}

void main() {
  final mockSodium = MockSodiumFFI();

  setUp(() {
    reset(mockSodium);
  });

  test('calls sodium_init', () {
    when(() => mockSodium.sodium_init()).thenReturn(0);

    SodiumInit.initFromFFI(mockSodium);

    verify(() => mockSodium.sodium_init());
  });

  test('throws if sodium_init fails', () {
    when(() => mockSodium.sodium_init()).thenReturn(-1);

    expect(
      () => SodiumInit.initFromFFI(mockSodium),
      throwsA(isA<SodiumException>()),
    );
  });

  test('returns SodiumFFI instance', () {
    when(() => mockSodium.sodium_init()).thenReturn(0);

    final sodium = SodiumInit.initFromFFI(mockSodium);
    expect(
      sodium,
      isA<SodiumFFI>().having((s) => s.sodium, 'sodium', mockSodium),
    );
  });
}
