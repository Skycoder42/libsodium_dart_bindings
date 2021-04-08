import 'dart:ffi';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/ffi/bindings/libsodium.ffi.dart';
import 'package:sodium/src/ffi/bindings/sodium_allocator.dart';
import 'package:test/test.dart';

class MockSodiumFFI extends Mock implements LibSodiumFFI {}

void main() {
  final nullptr = Pointer<Void>.fromAddress(0);

  final mockSodium = MockSodiumFFI();

  late SodiumAllocator sut;

  setUp(() {
    reset(mockSodium);

    sut = SodiumAllocator(mockSodium);
  });

  group('allocate', () {
    test('allocates secure memory', () {
      const bytes = 42;
      when(() => mockSodium.sodium_malloc(any())).thenReturn(nullptr);

      final ptr = sut.allocate<Uint16>(bytes);
      expect(ptr, nullptr);

      verify(() => mockSodium.sodium_malloc(bytes));
    });

    test('throws if alignment is required', () {
      expect(
        () => sut.allocate<Uint8>(4, alignment: 4),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  test('free uses secure free', () {
    sut.free(nullptr);

    verify(() => mockSodium.sodium_free(nullptr));
  });
}
