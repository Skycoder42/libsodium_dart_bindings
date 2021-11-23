@OnPlatform(<String, dynamic>{'!dart-vm': Skip('Requires dart:ffi')})

import 'dart:ffi';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/ffi/bindings/libsodium.ffi.dart';
import 'package:sodium/src/ffi/bindings/memory_protection.dart';
import 'package:sodium/src/ffi/bindings/sodium_allocator.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

import '../../../test_data.dart';
import '../pointer_test_helpers.dart';

class MockSodiumFFI extends Mock implements LibSodiumFFI {}

void main() {
  final mockSodium = MockSodiumFFI();

  late SodiumAllocator sut;

  setUpAll(() {
    registerPointers();
  });

  setUp(() {
    reset(mockSodium);

    sut = SodiumAllocator(mockSodium);
  });

  group('allocate', () {
    test('allocates secure memory with sodium_malloc', () {
      const bytes = 10;
      final testPtr = Pointer<Uint16>.fromAddress(42);
      when(() => mockSodium.sodium_malloc(any())).thenReturn(testPtr.cast());

      final ptr = sut.allocate<Uint16>(bytes);
      expect(ptr, testPtr);

      verify(() => mockSodium.sodium_malloc(bytes));
    });

    test('throws if alignment is required', () {
      expect(
        () => sut.allocate<Uint8>(4, alignment: 4),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  test('free uses sodium_free', () {
    final testPtr = Pointer<Uint16>.fromAddress(111);
    sut.free(testPtr);

    verify(() => mockSodium.sodium_free(testPtr.cast()));
  });

  test('memzero uses sodium_memzero', () {
    final testPtr = Pointer<Uint16>.fromAddress(111);
    const ptrLen = 10;

    sut.memzero(testPtr, ptrLen);

    verify(() => mockSodium.sodium_memzero(testPtr.cast(), ptrLen));
  });

  group('lock', () {
    test('uses sodium_mlock', () {
      when(() => mockSodium.sodium_mlock(any(), any())).thenReturn(0);

      final testPtr = Pointer<Uint16>.fromAddress(111);
      const ptrLen = 10;

      sut.lock(testPtr, ptrLen);

      verify(() => mockSodium.sodium_mlock(testPtr.cast(), ptrLen));
    });

    testData<Tuple2<int, bool>>(
      'result result of native operation',
      const [
        Tuple2(0, true),
        Tuple2(1, false),
        Tuple2(10, false),
        Tuple2(-1, false),
      ],
      (fixture) {
        when(() => mockSodium.sodium_mlock(any(), any()))
            .thenReturn(fixture.item1);

        final res = sut.lock(nullptr, 0);

        expect(res, fixture.item2);
      },
    );
  });

  group('unlock', () {
    test('uses sodium_unlock', () {
      when(() => mockSodium.sodium_munlock(any(), any())).thenReturn(0);

      final testPtr = Pointer<Uint16>.fromAddress(111);
      const ptrLen = 10;

      sut.unlock(testPtr, ptrLen);

      verify(() => mockSodium.sodium_munlock(testPtr.cast(), ptrLen));
    });

    testData<Tuple2<int, bool>>(
      'result result of native operation',
      const [
        Tuple2(0, true),
        Tuple2(1, false),
        Tuple2(10, false),
        Tuple2(-1, false),
      ],
      (fixture) {
        when(() => mockSodium.sodium_munlock(any(), any()))
            .thenReturn(fixture.item1);

        final res = sut.unlock(nullptr, 0);

        expect(res, fixture.item2);
      },
    );
  });

  group('memoryProtect', () {
    group('MemoryProtection.noAccess', () {
      test('uses sodium_mprotect_noaccess', () {
        when(() => mockSodium.sodium_mprotect_noaccess(any())).thenReturn(0);

        final testPtr = Pointer<Uint16>.fromAddress(111);

        sut.memoryProtect(testPtr, MemoryProtection.noAccess);

        verify(() => mockSodium.sodium_mprotect_noaccess(testPtr.cast()));
      });

      testData<Tuple2<int, bool>>(
        'result result of native operation',
        const [
          Tuple2(0, true),
          Tuple2(1, false),
          Tuple2(10, false),
          Tuple2(-1, false),
        ],
        (fixture) {
          when(() => mockSodium.sodium_mprotect_noaccess(any()))
              .thenReturn(fixture.item1);

          final res = sut.memoryProtect(nullptr, MemoryProtection.noAccess);

          expect(res, fixture.item2);
        },
      );
    });

    group('MemoryProtection.readOnly', () {
      test('uses sodium_mprotect_noaccess', () {
        when(() => mockSodium.sodium_mprotect_readonly(any())).thenReturn(0);

        final testPtr = Pointer<Uint16>.fromAddress(111);

        sut.memoryProtect(testPtr, MemoryProtection.readOnly);

        verify(() => mockSodium.sodium_mprotect_readonly(testPtr.cast()));
      });

      testData<Tuple2<int, bool>>(
        'result result of native operation',
        const [
          Tuple2(0, true),
          Tuple2(1, false),
          Tuple2(10, false),
          Tuple2(-1, false),
        ],
        (fixture) {
          when(() => mockSodium.sodium_mprotect_readonly(any()))
              .thenReturn(fixture.item1);

          final res = sut.memoryProtect(nullptr, MemoryProtection.readOnly);

          expect(res, fixture.item2);
        },
      );
    });

    group('MemoryProtection.readWrite', () {
      test('uses sodium_mprotect_noaccess', () {
        when(() => mockSodium.sodium_mprotect_readwrite(any())).thenReturn(0);

        final testPtr = Pointer<Uint16>.fromAddress(111);

        sut.memoryProtect(testPtr, MemoryProtection.readWrite);

        verify(() => mockSodium.sodium_mprotect_readwrite(testPtr.cast()));
      });

      testData<Tuple2<int, bool>>(
        'result result of native operation',
        const [
          Tuple2(0, true),
          Tuple2(1, false),
          Tuple2(10, false),
          Tuple2(-1, false),
        ],
        (fixture) {
          when(() => mockSodium.sodium_mprotect_readwrite(any()))
              .thenReturn(fixture.item1);

          final res = sut.memoryProtect(nullptr, MemoryProtection.readWrite);

          expect(res, fixture.item2);
        },
      );
    });
  });
}
