// ignore_for_file: unnecessary_lambdas for mocking
// ignore_for_file: type_literal_in_constant_pattern, switch_on_type for testing

@TestOn('dart-vm')
library;

import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/ffi/bindings/libsodium.ffi.wrapper.dart';
import 'package:sodium/src/ffi/bindings/memory_protection.dart';
import 'package:sodium/src/ffi/bindings/sodium_finalizer.dart';
import 'package:sodium/src/ffi/bindings/sodium_pointer.dart';
import 'package:test/test.dart';

import '../../../test_data.dart';
import '../pointer_test_helpers.dart';

class MockSodiumFFI extends Mock implements LibSodiumFFI {}

class MockSodiumFinalizer extends Mock implements SodiumFinalizer {}

void main() {
  final mockSodium = MockSodiumFFI();
  final mockSodiumFinalizer = MockSodiumFinalizer();

  setUpAll(() {
    registerPointers();
  });

  setUp(() {
    reset(mockSodium);
    reset(mockSodiumFinalizer);

    when(() => mockSodium.sodium_malloc(any())).thenReturn(nullptr);
    when(() => mockSodium.sodium_allocarray(any(), any())).thenReturn(nullptr);

    SodiumPointer.debugOverwriteFinalizer = mockSodiumFinalizer;
  });

  group('construction', () {
    final fakePtr = Pointer<Uint16>.fromAddress(666);

    setUp(() {
      when(() => mockSodium.sodium_malloc(any())).thenReturn(fakePtr.cast());
      when(
        () => mockSodium.sodium_allocarray(any(), any()),
      ).thenReturn(fakePtr.cast());
    });

    test('raw initializes members and attaches finalizer', () {
      final sut = SodiumPointer<Uint16>.raw(mockSodium, fakePtr, 4);

      expect(sut.sodium, mockSodium);
      expect(sut.ptr, fakePtr);

      expect(sut.locked, isTrue);
      expect(sut.memoryProtection, MemoryProtection.readWrite);

      expect(sut.elementSize, sizeOf<Uint16>());
      expect(sut.count, 4);
      expect(sut.byteLength, 4 * sizeOf<Uint16>());

      verify(
        () => mockSodiumFinalizer.attach(
          sut,
          fakePtr.cast(),
          4 * sizeOf<Uint16>(),
        ),
      );
    });

    group('alloc', () {
      test('allocates memory for one element', () {
        final sut = SodiumPointer<Uint16>.alloc(mockSodium);
        expect(sut.ptr, fakePtr);

        expect(sut.elementSize, sizeOf<Uint16>());
        expect(sut.count, 1);
        expect(sut.byteLength, sizeOf<Uint16>());

        verify(() => mockSodium.sodium_malloc(sizeOf<Uint16>()));
        verify(
          () =>
              mockSodiumFinalizer.attach(sut, sut.ptr.cast(), sizeOf<Uint16>()),
        );
      });

      test('allocates memory for multiple elements', () {
        final sut = SodiumPointer<Uint16>.alloc(mockSodium, count: 10);
        expect(sut.ptr, fakePtr);

        expect(sut.elementSize, sizeOf<Uint16>());
        expect(sut.count, 10);
        expect(sut.byteLength, 10 * sizeOf<Uint16>());

        verify(() => mockSodium.sodium_allocarray(10, sizeOf<Uint16>()));
        verify(
          () => mockSodiumFinalizer.attach(
            sut,
            sut.ptr.cast(),
            10 * sizeOf<Uint16>(),
          ),
        );
      });

      test('asserts for a negative number of elements', () {
        expect(
          () => SodiumPointer<Uint8>.alloc(mockSodium, count: -1),
          throwsA(isA<RangeError>()),
        );
      });

      testData<(SodiumPointer<dynamic> Function(), int)>(
        'allocates correct element size for supported types',
        [
          (
            () => SodiumPointer<Uint8>.alloc(mockSodium, count: 2),
            sizeOf<Uint8>(),
          ),
          (
            () => SodiumPointer<Uint16>.alloc(mockSodium, count: 2),
            sizeOf<Uint16>(),
          ),
          (
            () => SodiumPointer<Uint32>.alloc(mockSodium, count: 2),
            sizeOf<Uint32>(),
          ),
          (
            () => SodiumPointer<Uint64>.alloc(mockSodium, count: 2),
            sizeOf<Uint64>(),
          ),
          (
            () => SodiumPointer<Int8>.alloc(mockSodium, count: 2),
            sizeOf<Int8>(),
          ),
          (
            () => SodiumPointer<Int16>.alloc(mockSodium, count: 2),
            sizeOf<Int16>(),
          ),
          (
            () => SodiumPointer<Int32>.alloc(mockSodium, count: 2),
            sizeOf<Int32>(),
          ),
          (
            () => SodiumPointer<Int64>.alloc(mockSodium, count: 2),
            sizeOf<Int64>(),
          ),
          (
            () => SodiumPointer<Float>.alloc(mockSodium, count: 2),
            sizeOf<Float>(),
          ),
          (
            () => SodiumPointer<Double>.alloc(mockSodium, count: 2),
            sizeOf<Double>(),
          ),
          (
            () => SodiumPointer<Char>.alloc(mockSodium, count: 2),
            sizeOf<Char>(),
          ),
          (
            () => SodiumPointer<Short>.alloc(mockSodium, count: 2),
            sizeOf<Short>(),
          ),
          (() => SodiumPointer<Int>.alloc(mockSodium, count: 2), sizeOf<Int>()),
          (
            () => SodiumPointer<Long>.alloc(mockSodium, count: 2),
            sizeOf<Long>(),
          ),
          (
            () => SodiumPointer<LongLong>.alloc(mockSodium, count: 2),
            sizeOf<LongLong>(),
          ),
          (
            () => SodiumPointer<UnsignedChar>.alloc(mockSodium, count: 2),
            sizeOf<UnsignedChar>(),
          ),
          (
            () => SodiumPointer<UnsignedShort>.alloc(mockSodium, count: 2),
            sizeOf<UnsignedShort>(),
          ),
          (
            () => SodiumPointer<UnsignedInt>.alloc(mockSodium, count: 2),
            sizeOf<UnsignedInt>(),
          ),
          (
            () => SodiumPointer<UnsignedLong>.alloc(mockSodium, count: 2),
            sizeOf<UnsignedLong>(),
          ),
          (
            () => SodiumPointer<UnsignedLongLong>.alloc(mockSodium, count: 2),
            sizeOf<UnsignedLongLong>(),
          ),
          (
            () => SodiumPointer<SignedChar>.alloc(mockSodium, count: 2),
            sizeOf<SignedChar>(),
          ),
          (
            () => SodiumPointer<IntPtr>.alloc(mockSodium, count: 2),
            sizeOf<IntPtr>(),
          ),
          (
            () => SodiumPointer<UintPtr>.alloc(mockSodium, count: 2),
            sizeOf<UintPtr>(),
          ),
          (
            () => SodiumPointer<Size>.alloc(mockSodium, count: 2),
            sizeOf<Size>(),
          ),
          (
            () => SodiumPointer<WChar>.alloc(mockSodium, count: 2),
            sizeOf<WChar>(),
          ),
        ],
        (fixture) {
          final sut = fixture.$1();
          expect(sut.elementSize, fixture.$2);
          expect(sut.count, 2);
          expect(sut.byteLength, 2 * fixture.$2);
        },
      );

      test('throws for unsupported pointer types', () {
        expect(
          () => SodiumPointer<Handle>.alloc(mockSodium),
          throwsA(isA<UnsupportedError>()),
        );
      });

      test('zeroes memory if enabled', () {
        final sut = SodiumPointer<Uint16>.alloc(
          mockSodium,
          count: 3,
          zeroMemory: true,
        );

        verify(() => mockSodium.sodium_memzero(fakePtr.cast(), sut.byteLength));
      });

      test('sets memory protection if enabled', () {
        when(() => mockSodium.sodium_mprotect_readonly(any())).thenReturn(0);

        SodiumPointer<Uint16>.alloc(
          mockSodium,
          count: 3,
          memoryProtection: MemoryProtection.readOnly,
        );

        verify(() => mockSodium.sodium_mprotect_readonly(fakePtr.cast()));
      });

      test('sets memory protection after memory erase', () {
        when(() => mockSodium.sodium_mprotect_noaccess(any())).thenReturn(0);

        SodiumPointer<Uint16>.alloc(
          mockSodium,
          memoryProtection: MemoryProtection.noAccess,
          zeroMemory: true,
        );

        verifyInOrder([
          () => mockSodium.sodium_memzero(fakePtr.cast(), 2),
          () => mockSodium.sodium_mprotect_noaccess(fakePtr.cast()),
        ]);
      });

      test('frees pointer if allocation fails', () {
        when(
          () => mockSodium.sodium_mprotect_noaccess(any()),
        ).thenThrow(Exception('error'));

        expect(
          () => SodiumPointer<Uint8>.alloc(
            mockSodium,
            count: 10,
            memoryProtection: MemoryProtection.noAccess,
          ),
          throwsA(isA<Exception>()),
        );

        final captured = verifyInOrder([
          () => mockSodium.sodium_allocarray(10, 1),
          () => mockSodiumFinalizer.attach(
            captureAny(),
            fakePtr.cast(),
            sizeOf<Uint8>() * 10,
          ),
          () => mockSodium.sodium_mprotect_noaccess(fakePtr.cast()),
          () => mockSodiumFinalizer.detach(captureAny()),
          () => mockSodium.sodium_free(fakePtr.cast()),
        ]).captured.expand<dynamic>((c) => c).toList();
        expect(captured, hasLength(2));
        expect(captured[0], same(captured[1]));
      });
    });

    group('fromList', () {
      setUp(() {
        mockAllocArray(mockSodium);
        SodiumPointer.debugOverwriteFinalizer = mockSodiumFinalizer;
      });

      test('allocates array for type and length', () {
        const rawList = [1, 2, 3];
        final sut = SodiumPointer<Uint16>.fromList(mockSodium, rawList);
        expect(sut.count, rawList.length);
        expect(sut.elementSize, sizeOf<Uint16>());

        verify(
          () => mockSodium.sodium_allocarray(rawList.length, sizeOf<Uint16>()),
        );
        verify(
          () => mockSodiumFinalizer.attach(
            sut,
            sut.ptr.cast(),
            sizeOf<Uint16>() * rawList.length,
          ),
        );
      });

      test('copies list bytes to new array', () {
        const rawList = [1, 2, 3, 4, 5];
        final sut = SodiumPointer<Uint8>.fromList(mockSodium, rawList);

        expect(sut.ptr, hasRawData<Uint8>(rawList));
      });

      test('applies memory protection after copying', () {
        final sut = SodiumPointer<Uint16>.fromList(mockSodium, const <int>[
          1,
          2,
          3,
        ], memoryProtection: MemoryProtection.noAccess);

        verify(() => mockSodium.sodium_mprotect_noaccess(sut.ptr.cast()));
      });

      test('frees pointer if allocation fails', () {
        when(
          () => mockSodium.sodium_mprotect_noaccess(any()),
        ).thenThrow(Exception('error'));

        expect(
          () => SodiumPointer<Uint8>.fromList(mockSodium, const <int>[
            1,
            2,
            3,
          ], memoryProtection: MemoryProtection.noAccess),
          throwsA(isA<Exception>()),
        );

        verifyInOrder([
          () => mockSodium.sodium_allocarray(3, 1),
          () => mockSodium.sodium_mprotect_noaccess(any()),
          () => mockSodium.sodium_free(any()),
        ]);
      });
    });
  });

  group('members', () {
    late SodiumPointer<Uint8> sut;

    setUp(() {
      sut = SodiumPointer.raw(mockSodium, Pointer.fromAddress(1234), 3);
    });

    group('locked', () {
      test('does nothing when trying to set to same state', () {
        sut.locked = true;

        verifyZeroInteractions(mockSodium);
      });

      group('locked', () {
        test('removes memory lock when set to false', () {
          when(() => mockSodium.sodium_munlock(any(), any())).thenReturn(0);

          sut.locked = false;

          expect(sut.locked, isFalse);

          verify(
            () => mockSodium.sodium_munlock(sut.ptr.cast(), sut.byteLength),
          );
        });

        test('throws and keeps old state if unlocking fails', () {
          when(() => mockSodium.sodium_munlock(any(), any())).thenReturn(1);

          expect(() => sut.locked = false, throwsA(isA<SodiumException>()));
          expect(sut.locked, isTrue);

          verify(
            () => mockSodium.sodium_munlock(sut.ptr.cast(), sut.byteLength),
          );
        });
      });

      group('unlocked', () {
        setUp(() {
          when(() => mockSodium.sodium_munlock(any(), any())).thenReturn(0);

          sut.locked = false;
          expect(sut.locked, isFalse);

          reset(mockSodium);
        });

        test('acquires memory lock when set to true', () {
          when(() => mockSodium.sodium_mlock(any(), any())).thenReturn(0);

          sut.locked = true;

          expect(sut.locked, isTrue);

          verify(() => mockSodium.sodium_mlock(sut.ptr.cast(), sut.byteLength));
        });

        test('throws and keeps old state if locking fails', () {
          when(() => mockSodium.sodium_mlock(any(), any())).thenReturn(1);

          expect(() => sut.locked = true, throwsA(isA<SodiumException>()));
          expect(sut.locked, isFalse);

          verify(() => mockSodium.sodium_mlock(sut.ptr.cast(), sut.byteLength));
        });
      });
    });

    group('memoryProtection', () {
      test('does nothing when trying to set to same state', () {
        sut.memoryProtection = MemoryProtection.readWrite;

        verifyZeroInteractions(mockSodium);
      });

      group('noAccess', () {
        test('updates memory protection state', () {
          when(() => mockSodium.sodium_mprotect_noaccess(any())).thenReturn(0);

          sut.memoryProtection = MemoryProtection.noAccess;

          expect(sut.memoryProtection, MemoryProtection.noAccess);
          verify(() => mockSodium.sodium_mprotect_noaccess(sut.ptr.cast()));
        });

        test('throws and keeps old state if protecting fails', () {
          when(() => mockSodium.sodium_mprotect_noaccess(any())).thenReturn(1);

          expect(
            () => sut.memoryProtection = MemoryProtection.noAccess,
            throwsA(isA<SodiumException>()),
          );
          expect(sut.memoryProtection, MemoryProtection.readWrite);
          verify(() => mockSodium.sodium_mprotect_noaccess(sut.ptr.cast()));
        });
      });

      group('readOnly', () {
        test('updates memory protection state', () {
          when(() => mockSodium.sodium_mprotect_readonly(any())).thenReturn(0);

          sut.memoryProtection = MemoryProtection.readOnly;

          expect(sut.memoryProtection, MemoryProtection.readOnly);
          verify(() => mockSodium.sodium_mprotect_readonly(sut.ptr.cast()));
        });

        test('throws and keeps old state if protecting fails', () {
          when(() => mockSodium.sodium_mprotect_readonly(any())).thenReturn(1);

          expect(
            () => sut.memoryProtection = MemoryProtection.readOnly,
            throwsA(isA<SodiumException>()),
          );
          expect(sut.memoryProtection, MemoryProtection.readWrite);
          verify(() => mockSodium.sodium_mprotect_readonly(sut.ptr.cast()));
        });
      });

      group('readWrite', () {
        setUp(() {
          when(() => mockSodium.sodium_mprotect_noaccess(any())).thenReturn(0);

          sut.memoryProtection = MemoryProtection.noAccess;
          expect(sut.memoryProtection, MemoryProtection.noAccess);

          reset(mockSodium);
        });

        test('updates memory protection state', () {
          when(() => mockSodium.sodium_mprotect_readwrite(any())).thenReturn(0);

          sut.memoryProtection = MemoryProtection.readWrite;

          expect(sut.memoryProtection, MemoryProtection.readWrite);
          verify(() => mockSodium.sodium_mprotect_readwrite(sut.ptr.cast()));
        });

        test('throws and keeps old state if protecting fails', () {
          when(() => mockSodium.sodium_mprotect_readwrite(any())).thenReturn(1);

          expect(
            () => sut.memoryProtection = MemoryProtection.readWrite,
            throwsA(isA<SodiumException>()),
          );
          expect(sut.memoryProtection, MemoryProtection.noAccess);
          verify(() => mockSodium.sodium_mprotect_readwrite(sut.ptr.cast()));
        });
      });
    });

    test('zeroMemory calls memzero', () {
      sut.zeroMemory();

      verify(() => mockSodium.sodium_memzero(sut.ptr.cast(), sut.byteLength));
    });

    group('viewAt', () {
      test('throws if offset exceeds count', () {
        expect(
          () => sut.viewAt(10),
          throwsA(isA<ArgumentError>().having((e) => e.name, 'name', 'offset')),
        );
      });

      test('throws if length exceeds count', () {
        expect(
          () => sut.viewAt(0, 10),
          throwsA(isA<ArgumentError>().having((e) => e.name, 'name', 'length')),
        );
      });

      test('throws if offset + length exceeds count', () {
        expect(
          () => sut.viewAt(1, 3),
          throwsA(isA<ArgumentError>().having((e) => e.name, 'name', 'length')),
        );
      });

      testData<(int, int?, int, int)>(
        'returns expected view address and length',
        const [
          (0, null, 1234, 3),
          (1, null, 1235, 2),
          (2, null, 1236, 1),
          (3, null, 1237, 0),
          (0, 2, 1234, 2),
          (1, 1, 1235, 1),
        ],
        (fixture) {
          final view = sut.viewAt(fixture.$1, fixture.$2);

          expect(view.ptr, Pointer.fromAddress(fixture.$3));
          expect(view.count, fixture.$4);
        },
        fixtureToString: (fixture) =>
            '(offset: ${fixture.$1}, length: ${fixture.$2}) '
            '-> (address: ${fixture.$3}, count: ${fixture.$4})',
      );

      test('dispose does not free views and does not detach', () {
        sut.viewAt(0).dispose();

        verifyNever(() => mockSodium.sodium_free(sut.ptr.cast()));
        verifyNever(() => mockSodiumFinalizer.detach(sut));
      });

      test('detach throws unsupported error', () {
        expect(() => sut.viewAt(0).detach(), throwsA(isUnsupportedError));

        verifyNever(() => mockSodiumFinalizer.detach(sut));
      });

      // TODO test dynamicElementAt ?
    });

    group('fill', () {
      test('throws if offset exceeds count', () {
        expect(
          () => sut.fill(<int>[], offset: 10),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('throws if length exceeds count', () {
        expect(
          () => sut.fill(List.filled(10, 0)),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('throws if offset + length exceeds count', () {
        expect(
          () => sut.fill(List.filled(3, 0), offset: 1),
          throwsA(isA<ArgumentError>()),
        );
      });

      testData<(List<int>, int, List<int>)>(
        'fills correct parts of memory',
        const [
          ([], 3, [1, 2, 3, 4, 5]),
          ([7, 8, 9], 0, [7, 8, 9, 4, 5]),
          ([7, 8], 2, [1, 2, 7, 8, 5]),
          ([9], 4, [1, 2, 3, 4, 9]),
          ([6, 7, 8, 9, 0], 0, [6, 7, 8, 9, 0]),
        ],
        (fixture) {
          const testData = [1, 2, 3, 4, 5];
          final ptr = calloc<Uint8>(testData.length);
          fillPointer(ptr, testData);
          final sut = SodiumPointer.raw(mockSodium, ptr, testData.length)
            ..fill(fixture.$1, offset: fixture.$2);

          expect(sut.asListView(), fixture.$3);
        },
        fixtureToString: (fixture) =>
            '(data: ${fixture.$1}, offset: ${fixture.$2}) '
            '-> ${fixture.$3}',
      );
    });

    group('dispose', () {
      test('detaches and frees the pointer', () {
        sut.dispose();

        verifyInOrder([
          () => mockSodiumFinalizer.detach(sut),
          () => mockSodium.sodium_free(sut.ptr.cast()),
        ]);
      });

      test('can be invoked multiple times safely', () {
        sut.dispose();

        verifyInOrder([
          () => mockSodiumFinalizer.detach(sut),
          () => mockSodium.sodium_free(sut.ptr.cast()),
        ]);

        clearInteractions(mockSodiumFinalizer);
        clearInteractions(mockSodium);

        sut.dispose();

        verifyZeroInteractions(mockSodiumFinalizer);
        verifyZeroInteractions(mockSodium);
      });
    });

    test('detach returns the detached address without freeing it', () {
      final address = sut.detach();

      expect(address, isNot(nullptr));

      verify(() => mockSodiumFinalizer.detach(sut));
      verifyNever(() => mockSodium.sodium_free(sut.ptr.cast()));
    });
  });

  group('list conversions', () {
    const testData = [0x41, 0x42, 0, 0x43, 0x44];

    setUp(() {
      mockAllocArray(mockSodium);
    });

    void testPointerListConversions<
      TPtr extends NativeType,
      TList extends List<int>
    >({
      required int elementSize,
      required Pointer<TPtr> Function(int lengthInBytes) alloc,
      required TList Function(List<int> data) createList,
      bool exactListType = true,
      void Function(SodiumPointer<TPtr> Function() getSut)? subTests,
    }) {
      late SodiumPointer<TPtr> sut;

      setUp(() {
        final ptr = alloc(testData.length * elementSize);
        for (var i = 0; i < testData.length; ++i) {
          ptr[i] = testData[i];
        }
        sut = SodiumPointer.raw(mockSodium, ptr, testData.length);
      });

      test('viewAt uses offset correctly', () {
        final view = sut.viewAt(2, 2);

        expect(view.count, 2);
        expect(
          view.ptr,
          hasRawData<TPtr>(testData.sublist(2, 4), sizeHint: elementSize),
        );
      });

      test('fill fills correct bytes', () {
        sut.fill(const [1, 2, 3], offset: 1);

        expect(sut.count, testData.length);
        expect(
          sut.ptr,
          hasRawData<TPtr>([
            testData[0],
            1,
            2,
            3,
            testData[4],
          ], sizeHint: elementSize),
        );
      });

      test('asListView returns memory view', () {
        final list = sut.asListView();
        expect(list, testData);
        if (exactListType) {
          expect(list, isA<TList>());
        } else {
          expect(list, isA<List<int>>());
          expect(list, isA<TypedData>());
        }

        list[0] = 10;
        list[1] = 11;
        expect(
          sut.ptr,
          hasRawData<TPtr>([
            10,
            11,
            ...testData.skip(2),
          ], sizeHint: elementSize),
        );

        sut.fill([20, 21], offset: 2);
        expect(list[2], 20);
        expect(list[3], 21);
      });

      test('asListView returns list that owns the pointer if true', () {
        SodiumPointer.debugOverwriteFinalizer = mockSodiumFinalizer;
        sut.memoryProtection = MemoryProtection.noAccess;
        clearInteractions(mockSodium);

        sut.asListView(owned: true);
        verifyInOrder([
          () => mockSodium.sodium_mprotect_readwrite(sut.ptr.cast()),
          () => mockSodiumFinalizer.detach(sut),
        ]);
      });

      test('toSodiumPointer copies list to pointer', () {
        final typedTestData = createList(testData.cast());

        final ptr = typedTestData.toSodiumPointer<TPtr>(
          mockSodium,
          memoryProtection: MemoryProtection.readOnly,
        );

        expect(ptr.sodium, mockSodium);
        expect(ptr.elementSize, elementSize);
        expect(ptr.count, testData.length);
        expect(ptr.memoryProtection, MemoryProtection.readOnly);
        expect(ptr.ptr, hasRawData<TPtr>(testData, sizeHint: elementSize));
      });

      subTests?.call(() => sut);
    }

    group('Int8', () {
      testPointerListConversions(
        elementSize: sizeOf<Int8>(),
        alloc: (bytes) => calloc<Int8>(bytes),
        createList: Int8List.fromList,
      );
    });

    group('Int16', () {
      testPointerListConversions(
        elementSize: sizeOf<Int16>(),
        alloc: (bytes) => calloc<Int16>(bytes),
        createList: Int16List.fromList,
      );
    });

    group('Int32', () {
      testPointerListConversions(
        elementSize: sizeOf<Int32>(),
        alloc: (bytes) => calloc<Int32>(bytes),
        createList: Int32List.fromList,
      );
    });

    group('Int64', () {
      testPointerListConversions(
        elementSize: sizeOf<Int64>(),
        alloc: (bytes) => calloc<Int64>(bytes),
        createList: Int64List.fromList,
      );
    });

    group('Uint8', () {
      testPointerListConversions(
        elementSize: sizeOf<Uint8>(),
        alloc: (bytes) => calloc<Uint8>(bytes),
        createList: Uint8List.fromList,
      );
    });

    group('Uint16', () {
      testPointerListConversions(
        elementSize: sizeOf<Uint16>(),
        alloc: (bytes) => calloc<Uint16>(bytes),
        createList: Uint16List.fromList,
      );
    });

    group('Uint32', () {
      testPointerListConversions(
        elementSize: sizeOf<Uint32>(),
        alloc: (bytes) => calloc<Uint32>(bytes),
        createList: Uint32List.fromList,
      );
    });

    group('Uint64', () {
      testPointerListConversions(
        elementSize: sizeOf<Uint64>(),
        alloc: (bytes) => calloc<Uint64>(bytes),
        createList: Uint64List.fromList,
      );
    });

    group('Char', () {
      testPointerListConversions<Char, Int8List>(
        elementSize: sizeOf<Char>(),
        alloc: (bytes) => calloc<Char>(bytes),
        createList: Int8List.fromList,
        exactListType: false,
        subTests: (getSut) {
          test('toDartString converts to utf8 string', () {
            final string = getSut().toDartString();

            expect(string, 'AB\x00CD');
          });

          test('toDartString converts to zero terminated utf8 string', () {
            final string = getSut().toDartString(zeroTerminated: true);

            expect(string, 'AB');
          });

          test('copies string to pointer', () {
            const string = 'AB\x00CD';

            final ptr = string.toSodiumPointer(
              mockSodium,
              memoryProtection: MemoryProtection.readOnly,
            );

            expect(ptr.sodium, mockSodium);
            expect(ptr.count, testData.length);
            expect(ptr.memoryProtection, MemoryProtection.readOnly);
            expect(ptr.ptr, hasRawData<Char>(testData));
          });

          test('copies zero terminated string to pointer', () {
            const string = 'AB\x00CD';

            final ptr = string.toSodiumPointer(
              mockSodium,
              zeroTerminated: true,
            );

            expect(ptr.sodium, mockSodium);
            expect(ptr.count, 2);
            expect(ptr.ptr, hasRawData<Char>(testData.sublist(0, 2)));
          });

          test('copies string to fixed width pointer', () {
            const string = 'AB';

            final ptr = string.toSodiumPointer(mockSodium, memoryWidth: 4);

            expect(ptr.sodium, mockSodium);
            expect(ptr.count, 4);
            expect(
              ptr.ptr,
              hasRawData<Char>([...testData.sublist(0, 2), 0, 0]),
            );
          });
        },
      );
    });

    group('Short', () {
      testPointerListConversions(
        elementSize: sizeOf<Short>(),
        alloc: (bytes) => calloc<Short>(bytes),
        createList: Int16List.fromList,
        exactListType: false,
      );
    });

    group('Int', () {
      testPointerListConversions(
        elementSize: sizeOf<Int>(),
        alloc: (bytes) => calloc<Int>(bytes),
        createList: Int32List.fromList,
        exactListType: false,
      );
    });

    group('Long', () {
      testPointerListConversions(
        elementSize: sizeOf<Long>(),
        alloc: (bytes) => calloc<Long>(bytes),
        createList: Int32List.fromList,
        exactListType: false,
      );
    });

    group('LongLong', () {
      testPointerListConversions(
        elementSize: sizeOf<LongLong>(),
        alloc: (bytes) => calloc<LongLong>(bytes),
        createList: Int64List.fromList,
        exactListType: false,
      );
    });

    group('UnsignedChar', () {
      testPointerListConversions(
        elementSize: sizeOf<UnsignedChar>(),
        alloc: (bytes) => calloc<UnsignedChar>(bytes),
        createList: Uint8List.fromList,
        exactListType: false,
      );
    });

    group('UnsignedShort', () {
      testPointerListConversions(
        elementSize: sizeOf<UnsignedShort>(),
        alloc: (bytes) => calloc<UnsignedShort>(bytes),
        createList: Uint16List.fromList,
        exactListType: false,
      );
    });

    group('UnsignedInt', () {
      testPointerListConversions(
        elementSize: sizeOf<UnsignedInt>(),
        alloc: (bytes) => calloc<UnsignedInt>(bytes),
        createList: Uint32List.fromList,
        exactListType: false,
      );
    });

    group('UnsignedLong', () {
      testPointerListConversions(
        elementSize: sizeOf<UnsignedLong>(),
        alloc: (bytes) => calloc<UnsignedLong>(bytes),
        createList: Uint32List.fromList,
        exactListType: false,
      );
    });

    group('UnsignedLongLong', () {
      testPointerListConversions(
        elementSize: sizeOf<UnsignedLongLong>(),
        alloc: (bytes) => calloc<UnsignedLongLong>(bytes),
        createList: Uint64List.fromList,
        exactListType: false,
      );
    });

    group('SignedChar', () {
      testPointerListConversions(
        elementSize: sizeOf<SignedChar>(),
        alloc: (bytes) => calloc<SignedChar>(bytes),
        createList: Int8List.fromList,
        exactListType: false,
      );
    });

    group('IntPtr', () {
      testPointerListConversions(
        elementSize: sizeOf<IntPtr>(),
        alloc: (bytes) => calloc<IntPtr>(bytes),
        createList: Int32List.fromList,
        exactListType: false,
      );
    });

    group('UintPtr', () {
      testPointerListConversions(
        elementSize: sizeOf<UintPtr>(),
        alloc: (bytes) => calloc<UintPtr>(bytes),
        createList: Uint32List.fromList,
        exactListType: false,
      );
    });

    group('Size', () {
      testPointerListConversions(
        elementSize: sizeOf<Size>(),
        alloc: (bytes) => calloc<Size>(bytes),
        createList: Uint32List.fromList,
        exactListType: false,
      );
    });

    group('WChar', () {
      testPointerListConversions(
        elementSize: sizeOf<WChar>(),
        alloc: (bytes) => calloc<WChar>(bytes),
        createList: Uint16List.fromList,
        exactListType: false,
      );
    });

    group('Float', () {
      late SodiumPointer<Float> sut;

      setUp(() {
        final ptr = calloc<Float>(testData.length * sizeOf<Float>());
        for (var i = 0; i < testData.length; ++i) {
          ptr[i] = testData[i].toDouble();
        }
        sut = SodiumPointer.raw(mockSodium, ptr, testData.length);
      });

      test('viewAt uses offset correctly', () {
        final view = sut.viewAt(2, 2);

        expect(view.count, 2);
        expect(view.ptr.asTypedList(view.count), testData.sublist(2, 4));
      });

      test('fill fills correct bytes', () {
        sut.fill(const [1.1, 2.2, 3.3], offset: 1);

        expect(sut.count, testData.length);
        expect(sut.ptr.asTypedList(sut.count), [
          testData[0],
          1.100000023841858,
          2.200000047683716,
          3.299999952316284,
          testData[4],
        ]);
      });

      test('asListView returns memory view', () {
        final list = sut.asListView();
        expect(list, testData);
        expect(list, isA<Float32List>());

        list[0] = 10.5;
        list[1] = 11.5;
        expect(sut.ptr.asTypedList(sut.count), [
          10.5,
          11.5,
          ...testData.skip(2),
        ]);

        sut.fill([20.2, 21.1], offset: 2);
        expect(list[2], 20.200000762939453);
        expect(list[3], 21.100000381469727);
      });

      test('toSodiumPointer copies list to pointer', () {
        final typedTestData = Float32List.fromList(
          testData.map((e) => e.toDouble()).toList(),
        );

        final ptr = typedTestData.toSodiumPointer<Float>(
          mockSodium,
          memoryProtection: MemoryProtection.readOnly,
        );

        expect(ptr.sodium, mockSodium);
        expect(ptr.elementSize, sizeOf<Float>());
        expect(ptr.count, testData.length);
        expect(ptr.memoryProtection, MemoryProtection.readOnly);
        expect(ptr.ptr.asTypedList(ptr.count), testData);
      });
    });

    group('Double', () {
      late SodiumPointer<Double> sut;

      setUp(() {
        final ptr = calloc<Double>(testData.length * sizeOf<Double>());
        for (var i = 0; i < testData.length; ++i) {
          ptr[i] = testData[i].toDouble();
        }
        sut = SodiumPointer.raw(mockSodium, ptr, testData.length);
      });

      test('viewAt uses offset correctly', () {
        final view = sut.viewAt(2, 2);

        expect(view.count, 2);
        expect(view.ptr.asTypedList(view.count), testData.sublist(2, 4));
      });

      test('fill fills correct bytes', () {
        sut.fill(const [1.1, 2.2, 3.3], offset: 1);

        expect(sut.count, testData.length);
        expect(sut.ptr.asTypedList(sut.count), [
          testData[0],
          1.1,
          2.2,
          3.3,
          testData[4],
        ]);
      });

      test('asListView returns memory view', () {
        final list = sut.asListView();
        expect(list, testData);
        expect(list, isA<Float64List>());

        list[0] = 10.5;
        list[1] = 11.5;
        expect(sut.ptr.asTypedList(sut.count), [
          10.5,
          11.5,
          ...testData.skip(2),
        ]);

        sut.fill([20.2, 21.1], offset: 2);
        expect(list[2], 20.2);
        expect(list[3], 21.1);
      });

      test('toSodiumPointer copies list to pointer', () {
        final typedTestData = Float64List.fromList(
          testData.map((e) => e.toDouble()).toList(),
        );

        final ptr = typedTestData.toSodiumPointer<Double>(
          mockSodium,
          memoryProtection: MemoryProtection.readOnly,
        );

        expect(ptr.sodium, mockSodium);
        expect(ptr.elementSize, sizeOf<Double>());
        expect(ptr.count, testData.length);
        expect(ptr.memoryProtection, MemoryProtection.readOnly);
        expect(ptr.ptr.asTypedList(ptr.count), testData);
      });
    });

    test('throws error if used on an untyped list', () {
      expect(
        () => <int>[].toSodiumPointer<Uint8>(mockSodium),
        throwsUnsupportedError,
      );
    });

    test('throw error if data does not fit into pointer', () {
      expect(
        () => Uint16List(0).toSodiumPointer<Uint8>(mockSodium),
        throwsArgumentError,
      );
      expect(
        () => Uint32List(0).toSodiumPointer<Uint8>(mockSodium),
        throwsArgumentError,
      );
      expect(
        () => Uint32List(0).toSodiumPointer<Uint16>(mockSodium),
        throwsArgumentError,
      );
      expect(
        () => Uint64List(0).toSodiumPointer<Uint8>(mockSodium),
        throwsArgumentError,
      );
      expect(
        () => Uint64List(0).toSodiumPointer<Uint16>(mockSodium),
        throwsArgumentError,
      );
      expect(
        () => Uint64List(0).toSodiumPointer<Uint32>(mockSodium),
        throwsArgumentError,
      );
    });
  });
}

extension _TestHelper<T extends NativeType> on Pointer<T> {
  void operator []=(int index, num value) {
    switch (T) {
      case Int8:
        Int8Pointer(this as Pointer<Int8>)[index] = value as int;
      case Int16:
        Int16Pointer(this as Pointer<Int16>)[index] = value as int;
      case Int32:
        Int32Pointer(this as Pointer<Int32>)[index] = value as int;
      case Int64:
        Int64Pointer(this as Pointer<Int64>)[index] = value as int;
      case Uint8:
        Uint8Pointer(this as Pointer<Uint8>)[index] = value as int;
      case Uint16:
        Uint16Pointer(this as Pointer<Uint16>)[index] = value as int;
      case Uint32:
        Uint32Pointer(this as Pointer<Uint32>)[index] = value as int;
      case Uint64:
        Uint64Pointer(this as Pointer<Uint64>)[index] = value as int;
      case Float:
        FloatPointer(this as Pointer<Float>)[index] = value as double;
      case Double:
        DoublePointer(this as Pointer<Double>)[index] = value as double;
      case Char:
        AbiSpecificIntegerPointer(this as Pointer<Char>)[index] = value as int;
      case Short:
        AbiSpecificIntegerPointer(this as Pointer<Short>)[index] = value as int;
      case Int:
        AbiSpecificIntegerPointer(this as Pointer<Int>)[index] = value as int;
      case Long:
        AbiSpecificIntegerPointer(this as Pointer<Long>)[index] = value as int;
      case LongLong:
        AbiSpecificIntegerPointer(this as Pointer<LongLong>)[index] =
            value as int;
      case UnsignedChar:
        AbiSpecificIntegerPointer(this as Pointer<UnsignedChar>)[index] =
            value as int;
      case UnsignedShort:
        AbiSpecificIntegerPointer(this as Pointer<UnsignedShort>)[index] =
            value as int;
      case UnsignedInt:
        AbiSpecificIntegerPointer(this as Pointer<UnsignedInt>)[index] =
            value as int;
      case UnsignedLong:
        AbiSpecificIntegerPointer(this as Pointer<UnsignedLong>)[index] =
            value as int;
      case UnsignedLongLong:
        AbiSpecificIntegerPointer(this as Pointer<UnsignedLongLong>)[index] =
            value as int;
      case SignedChar:
        AbiSpecificIntegerPointer(this as Pointer<SignedChar>)[index] =
            value as int;
      case IntPtr:
        AbiSpecificIntegerPointer(this as Pointer<IntPtr>)[index] =
            value as int;
      case UintPtr:
        AbiSpecificIntegerPointer(this as Pointer<UintPtr>)[index] =
            value as int;
      case Size:
        AbiSpecificIntegerPointer(this as Pointer<Size>)[index] = value as int;
      case WChar:
        AbiSpecificIntegerPointer(this as Pointer<WChar>)[index] = value as int;
      default:
        throw UnsupportedError(
          'Cannot create a SodiumPointer for $T. T must be a primitive type',
        );
    }
  }
}
