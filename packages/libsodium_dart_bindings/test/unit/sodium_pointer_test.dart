import 'dart:ffi';

import 'package:libsodium_dart_bindings/src/ffi/bindings/sodium_pointer.dart';
import 'package:libsodium_dart_bindings/src/ffi/bindings/sodium.ffi.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockSodiumFFI extends Mock implements SodiumFFI {}

void main() {
  final mockSodium = MockSodiumFFI();

  setUp(() {
    reset(mockSodium);

    when(() => mockSodium.sodium_malloc(any()))
        .thenReturn(Pointer<Void>.fromAddress(0));
    when(() => mockSodium.sodium_allocarray(any(), any()))
        .thenReturn(Pointer<Void>.fromAddress(0));
  });

  group('construction', () {
    final mockPtr = Pointer<Uint16>.fromAddress(0);

    test('raw initializes members', () {
      final sut = SodiumPointer<Uint16>.raw(mockSodium, mockPtr, 4);

      expect(sut.sodium, mockSodium);
      expect(sut.ptr, mockPtr);

      expect(sut.locked, isTrue);
      expect(sut.memoryProtection, MemoryProtection.readWrite);

      expect(sut.elementSize, sizeOf<Uint16>());
      expect(sut.count, 4);
      expect(sut.byteLength, 8);
    });

    test('alloc allocates memory for one element', () {
      final sut = SodiumPointer<Uint32>.alloc(mockSodium);
      expect(sut.ptr, isNotNull);

      expect(sut.elementSize, sizeOf<Uint32>());
      expect(sut.count, 1);
      expect(sut.byteLength, 4);

      verify(() => mockSodium.sodium_malloc(4));
    });

    test('alloc allocates memory for multiple elements', () {
      final sut = SodiumPointer<Uint32>.alloc(mockSodium, count: 10);
      expect(sut.ptr, isNotNull);

      expect(sut.elementSize, sizeOf<Uint32>());
      expect(sut.count, 10);
      expect(sut.byteLength, 40);

      verify(() => mockSodium.sodium_allocarray(10, 4));
    });

    test('alloc asserts for a negative number of elements', () {
      expect(
        () => SodiumPointer<Uint8>.alloc(mockSodium, count: -1),
        throwsA(isA<RangeError>()),
      );
    });
  });
}
