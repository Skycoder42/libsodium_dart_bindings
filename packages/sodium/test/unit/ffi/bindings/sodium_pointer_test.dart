import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/ffi/bindings/libsodium.ffi.dart';
import 'package:sodium/src/ffi/bindings/sodium_pointer.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

import '../../../test_data.dart';

class MockSodiumFFI extends Mock implements LibSodiumFFI {}

class MockSodiumPointer<T extends NativeType> extends Mock
    implements SodiumPointer<T> {}

void main() {
  final nullptr = Pointer<Void>.fromAddress(0);

  final mockSodium = MockSodiumFFI();

  setUpAll(() {
    registerFallbackValue<Pointer<Void>>(nullptr);
  });

  setUp(() {
    reset(mockSodium);

    when(() => mockSodium.sodium_malloc(any())).thenReturn(nullptr);
    when(() => mockSodium.sodium_allocarray(any(), any())).thenReturn(nullptr);
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

    group('alloc', () {
      test('allocates memory for one element', () {
        final sut = SodiumPointer<Uint32>.alloc(mockSodium);
        expect(sut.ptr, isNotNull);

        expect(sut.elementSize, sizeOf<Uint32>());
        expect(sut.count, 1);
        expect(sut.byteLength, 4);

        verify(() => mockSodium.sodium_malloc(4));
      });

      test('allocates memory for multiple elements', () {
        final sut = SodiumPointer<Uint32>.alloc(mockSodium, count: 10);
        expect(sut.ptr, isNotNull);

        expect(sut.elementSize, sizeOf<Uint32>());
        expect(sut.count, 10);
        expect(sut.byteLength, 40);

        verify(() => mockSodium.sodium_allocarray(10, 4));
      });

      test('asserts for a negative number of elements', () {
        expect(
          () => SodiumPointer<Uint8>.alloc(mockSodium, count: -1),
          throwsA(isA<RangeError>()),
        );
      });

      testData<Tuple2<SodiumPointer<dynamic> Function(), int>>(
        'allocates correct element size for supported types',
        [
          Tuple2(() => SodiumPointer<Uint8>.alloc(mockSodium, count: 2), 1),
          Tuple2(() => SodiumPointer<Uint16>.alloc(mockSodium, count: 2), 2),
          Tuple2(() => SodiumPointer<Uint32>.alloc(mockSodium, count: 2), 4),
          Tuple2(() => SodiumPointer<Uint64>.alloc(mockSodium, count: 2), 8),
          Tuple2(() => SodiumPointer<Int8>.alloc(mockSodium, count: 2), 1),
          Tuple2(() => SodiumPointer<Int16>.alloc(mockSodium, count: 2), 2),
          Tuple2(() => SodiumPointer<Int32>.alloc(mockSodium, count: 2), 4),
          Tuple2(() => SodiumPointer<Int64>.alloc(mockSodium, count: 2), 8),
          Tuple2(() => SodiumPointer<Float>.alloc(mockSodium, count: 2), 4),
          Tuple2(() => SodiumPointer<Double>.alloc(mockSodium, count: 2), 8),
        ],
        (fixture) {
          final sut = fixture.item1();
          expect(sut.elementSize, fixture.item2);
          expect(sut.count, 2);
          expect(sut.byteLength, 2 * fixture.item2);
        },
      );

      test('throws for unsupported pointer types', () {
        expect(
          () => SodiumPointer<IntPtr>.alloc(mockSodium),
          throwsA(isA<UnsupportedError>()),
        );
      });

      test('zeroes memory if enabled', () {
        final sut = SodiumPointer<Uint16>.alloc(
          mockSodium,
          count: 3,
          zeroMemory: true,
        );

        verify(() => mockSodium.sodium_memzero(nullptr, sut.byteLength));
      });

      test('sets memory protection if enabled', () {
        when(() => mockSodium.sodium_mprotect_readonly(any())).thenReturn(0);

        SodiumPointer<Uint16>.alloc(
          mockSodium,
          count: 3,
          memoryProtection: MemoryProtection.readOnly,
        );

        verify(() => mockSodium.sodium_mprotect_readonly(nullptr));
      });

      test('sets memory protection after memory erase', () {
        when(() => mockSodium.sodium_mprotect_noaccess(any())).thenReturn(0);

        SodiumPointer<Uint16>.alloc(
          mockSodium,
          memoryProtection: MemoryProtection.noAccess,
          zeroMemory: true,
        );

        verifyInOrder([
          () => mockSodium.sodium_memzero(nullptr, 2),
          () => mockSodium.sodium_mprotect_noaccess(nullptr),
        ]);
      });

      test('frees pointer if allocation fails', () {
        when(() => mockSodium.sodium_mprotect_noaccess(any()))
            .thenThrow(Exception('error'));

        expect(
          () => SodiumPointer<Uint8>.alloc(
            mockSodium,
            count: 10,
            memoryProtection: MemoryProtection.noAccess,
          ),
          throwsA(isA<Exception>()),
        );

        verifyInOrder([
          () => mockSodium.sodium_allocarray(10, 1),
          () => mockSodium.sodium_mprotect_noaccess(nullptr),
          () => mockSodium.sodium_free(nullptr),
        ]);
      });
    });

    group('fromList', () {
      setUp(() {
        when(() => mockSodium.sodium_allocarray(any(), any())).thenAnswer(
          (i) => calloc<Uint8>(
            (i.positionalArguments[0] as int) *
                (i.positionalArguments[1] as int),
          ).cast(),
        );
      });

      test('allocates array for type and length', () {
        const rawList = [1, 2, 3];
        final sut = SodiumPointer<Uint16>.fromList(mockSodium, rawList);
        expect(sut.count, rawList.length);
        expect(sut.elementSize, 2);

        verify(() => mockSodium.sodium_allocarray(rawList.length, 2));
      });

      test('copies list bytes to new array', () {
        const rawList = [1, 2, 3, 4, 5];
        final sut = SodiumPointer<Uint16>.fromList(mockSodium, rawList);

        final rawPtr = sut.ptr;
        for (var i = 0; i < rawList.length; ++i) {
          expect(rawPtr.elementAt(i).value, rawList[i]);
        }
      });

      test('applies memory protection after coyping', () {
        when(() => mockSodium.sodium_mprotect_noaccess(any())).thenReturn(0);

        final sut = SodiumPointer<Uint16>.fromList(
          mockSodium,
          const <int>[1, 2, 3],
          memoryProtection: MemoryProtection.noAccess,
        );

        verify(() => mockSodium.sodium_mprotect_noaccess(sut.ptr.cast()));
      });

      test('frees pointer if allocation fails', () {
        when(() => mockSodium.sodium_mprotect_noaccess(any()))
            .thenThrow(Exception('error'));

        expect(
          () => SodiumPointer<Uint8>.fromList(
            mockSodium,
            const <int>[1, 2, 3],
            memoryProtection: MemoryProtection.noAccess,
          ),
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
    late SodiumPointer<Uint16> sut;

    setUp(() {
      sut = SodiumPointer.raw(mockSodium, nullptr.cast(), 3);
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
              () => mockSodium.sodium_munlock(sut.ptr.cast(), sut.byteLength));
        });

        test('throws and keeps old state if unlocking fails', () {
          when(() => mockSodium.sodium_munlock(any(), any())).thenReturn(1);

          expect(() => sut.locked = false, throwsA(isA<SodiumException>()));
          expect(sut.locked, isTrue);

          verify(
              () => mockSodium.sodium_munlock(sut.ptr.cast(), sut.byteLength));
        });
      });

      group('unlocked', () {
        setUp(() {
          when(() => mockSodium.sodium_munlock(any(), any())).thenReturn(0);

          sut.locked = false;
          assert(!sut.locked);

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
          assert(sut.memoryProtection == MemoryProtection.noAccess);

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

    test('dispose frees the pointer', () {
      sut.dispose();

      verify(() => mockSodium.sodium_free(sut.ptr.cast()));
    });
  });

  group('list conversions', () {
    const testData = [0x41, 0x42, 0, 0x43, 0x44];

    setUp(() {
      when(() => mockSodium.sodium_mprotect_readonly(any())).thenReturn(0);
      when(() => mockSodium.sodium_allocarray(any(), any())).thenAnswer(
        (i) => calloc<Uint8>(
          (i.positionalArguments[0] as int) * (i.positionalArguments[1] as int),
        ).cast(),
      );
    });

    group('Int8', () {
      late SodiumPointer<Int8> sut;

      setUp(() {
        final ptr = calloc<Int8>(testData.length * sizeOf<Int8>());
        ptr.asTypedList(testData.length).setAll(0, testData);
        sut = SodiumPointer.raw(mockSodium, ptr, testData.length);
      });

      test('asList returns memory view', () {
        final list = sut.asList();
        expect(list, testData);

        list[0] = 10;
        expect(sut.ptr.elementAt(0).value, 10);

        sut.ptr.elementAt(1).value = 20;
        expect(list[1], 20);
      });

      test('copyAsList returns memory copy', () {
        final list = sut.copyAsList();
        expect(list, testData);

        list[0] = 10;
        expect(sut.ptr.elementAt(0).value, 0x41);

        sut.ptr.elementAt(1).value = 20;
        expect(list[1], 0x42);
      });

      test('toDartString converts to utf8 string', () {
        final string = sut.toDartString();

        expect(string, 'AB\x00CD');
      });

      test('toDartString converts to zero terminated utf8 string', () {
        final string = sut.toDartString(zeroTerminated: true);

        expect(string, 'AB');
      });

      test('copies list to pointer', () {
        final typedTestData = Int8List.fromList(testData);

        final ptr = typedTestData.toSodiumPointer(
          mockSodium,
          memoryProtection: MemoryProtection.readOnly,
        );

        expect(ptr.sodium, mockSodium);
        expect(ptr.count, testData.length);
        expect(ptr.memoryProtection, MemoryProtection.readOnly);
        for (var i = 0; i < testData.length; ++i) {
          expect(ptr.ptr.elementAt(i).value, testData[i]);
        }
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
        for (var i = 0; i < testData.length; ++i) {
          expect(ptr.ptr.elementAt(i).value, testData[i]);
        }
      });

      test('copies zero terminated string to pointer', () {
        const string = 'AB\x00CD';

        final ptr = string.toSodiumPointer(mockSodium, zeroTerminated: true);

        expect(ptr.sodium, mockSodium);
        expect(ptr.count, 2);
        for (var i = 0; i < 2; ++i) {
          expect(ptr.ptr.elementAt(i).value, testData[i]);
        }
      });

      test('copies string to fixed width pointer', () {
        const string = 'AB';

        final ptr = string.toSodiumPointer(mockSodium, memoryWidth: 4);

        expect(ptr.sodium, mockSodium);
        expect(ptr.count, 4);
        for (var i = 0; i < 2; ++i) {
          expect(ptr.ptr.elementAt(i).value, testData[i]);
        }
        for (var i = 2; i < 4; ++i) {
          expect(ptr.ptr.elementAt(i).value, 0);
        }
      });
    });

    group('Int16', () {
      late SodiumPointer<Int16> sut;

      setUp(() {
        final ptr = calloc<Int16>(testData.length * sizeOf<Int16>());
        ptr.asTypedList(testData.length).setAll(0, testData);
        sut = SodiumPointer.raw(mockSodium, ptr, testData.length);
      });

      test('asList returns memory view', () {
        final list = sut.asList();
        expect(list, testData);

        list[0] = 10;
        expect(sut.ptr.elementAt(0).value, 10);

        sut.ptr.elementAt(1).value = 20;
        expect(list[1], 20);
      });

      test('copyAsList returns memory copy', () {
        final list = sut.copyAsList();
        expect(list, testData);

        list[0] = 10;
        expect(sut.ptr.elementAt(0).value, 0x41);

        sut.ptr.elementAt(1).value = 20;
        expect(list[1], 0x42);
      });

      test('copies list to pointer', () {
        final typedTestData = Int16List.fromList(testData);

        final ptr = typedTestData.toSodiumPointer(
          mockSodium,
          memoryProtection: MemoryProtection.readOnly,
        );

        expect(ptr.sodium, mockSodium);
        expect(ptr.count, testData.length);
        expect(ptr.memoryProtection, MemoryProtection.readOnly);
        for (var i = 0; i < testData.length; ++i) {
          expect(ptr.ptr.elementAt(i).value, testData[i]);
        }
      });
    });

    group('Int32', () {
      late SodiumPointer<Int32> sut;

      setUp(() {
        final ptr = calloc<Int32>(testData.length * sizeOf<Int32>());
        ptr.asTypedList(testData.length).setAll(0, testData);
        sut = SodiumPointer.raw(mockSodium, ptr, testData.length);
      });

      test('asList returns memory view', () {
        final list = sut.asList();
        expect(list, testData);

        list[0] = 10;
        expect(sut.ptr.elementAt(0).value, 10);

        sut.ptr.elementAt(1).value = 20;
        expect(list[1], 20);
      });

      test('copyAsList returns memory copy', () {
        final list = sut.copyAsList();
        expect(list, testData);

        list[0] = 10;
        expect(sut.ptr.elementAt(0).value, 0x41);

        sut.ptr.elementAt(1).value = 20;
        expect(list[1], 0x42);
      });

      test('copies list to pointer', () {
        final typedTestData = Int32List.fromList(testData);

        final ptr = typedTestData.toSodiumPointer(
          mockSodium,
          memoryProtection: MemoryProtection.readOnly,
        );

        expect(ptr.sodium, mockSodium);
        expect(ptr.count, testData.length);
        expect(ptr.memoryProtection, MemoryProtection.readOnly);
        for (var i = 0; i < testData.length; ++i) {
          expect(ptr.ptr.elementAt(i).value, testData[i]);
        }
      });
    });

    group('Int64', () {
      late SodiumPointer<Int64> sut;

      setUp(() {
        final ptr = calloc<Int64>(testData.length * sizeOf<Int64>());
        ptr.asTypedList(testData.length).setAll(0, testData);
        sut = SodiumPointer.raw(mockSodium, ptr, testData.length);
      });

      test('asList returns memory view', () {
        final list = sut.asList();
        expect(list, testData);

        list[0] = 10;
        expect(sut.ptr.elementAt(0).value, 10);

        sut.ptr.elementAt(1).value = 20;
        expect(list[1], 20);
      });

      test('copyAsList returns memory copy', () {
        final list = sut.copyAsList();
        expect(list, testData);

        list[0] = 10;
        expect(sut.ptr.elementAt(0).value, 0x41);

        sut.ptr.elementAt(1).value = 20;
        expect(list[1], 0x42);
      });

      test('copies list to pointer', () {
        final typedTestData = Int64List.fromList(testData);

        final ptr = typedTestData.toSodiumPointer(
          mockSodium,
          memoryProtection: MemoryProtection.readOnly,
        );

        expect(ptr.sodium, mockSodium);
        expect(ptr.count, testData.length);
        expect(ptr.memoryProtection, MemoryProtection.readOnly);
        for (var i = 0; i < testData.length; ++i) {
          expect(ptr.ptr.elementAt(i).value, testData[i]);
        }
      });
    });

    group('Uint8', () {
      late SodiumPointer<Uint8> sut;

      setUp(() {
        final ptr = calloc<Uint8>(testData.length * sizeOf<Uint8>());
        ptr.asTypedList(testData.length).setAll(0, testData);
        sut = SodiumPointer.raw(mockSodium, ptr, testData.length);
      });

      test('asList returns memory view', () {
        final list = sut.asList();
        expect(list, testData);

        list[0] = 10;
        expect(sut.ptr.elementAt(0).value, 10);

        sut.ptr.elementAt(1).value = 20;
        expect(list[1], 20);
      });

      test('copyAsList returns memory copy', () {
        final list = sut.copyAsList();
        expect(list, testData);

        list[0] = 10;
        expect(sut.ptr.elementAt(0).value, 0x41);

        sut.ptr.elementAt(1).value = 20;
        expect(list[1], 0x42);
      });

      test('copies list to pointer', () {
        final typedTestData = Uint8List.fromList(testData);

        final ptr = typedTestData.toSodiumPointer(
          mockSodium,
          memoryProtection: MemoryProtection.readOnly,
        );

        expect(ptr.sodium, mockSodium);
        expect(ptr.count, testData.length);
        expect(ptr.memoryProtection, MemoryProtection.readOnly);
        for (var i = 0; i < testData.length; ++i) {
          expect(ptr.ptr.elementAt(i).value, testData[i]);
        }
      });
    });

    group('Uint16', () {
      late SodiumPointer<Uint16> sut;

      setUp(() {
        final ptr = calloc<Uint16>(testData.length * sizeOf<Uint16>());
        ptr.asTypedList(testData.length).setAll(0, testData);
        sut = SodiumPointer.raw(mockSodium, ptr, testData.length);
      });

      test('asList returns memory view', () {
        final list = sut.asList();
        expect(list, testData);

        list[0] = 10;
        expect(sut.ptr.elementAt(0).value, 10);

        sut.ptr.elementAt(1).value = 20;
        expect(list[1], 20);
      });

      test('copyAsList returns memory copy', () {
        final list = sut.copyAsList();
        expect(list, testData);

        list[0] = 10;
        expect(sut.ptr.elementAt(0).value, 0x41);

        sut.ptr.elementAt(1).value = 20;
        expect(list[1], 0x42);
      });

      test('copies list to pointer', () {
        final typedTestData = Uint16List.fromList(testData);

        final ptr = typedTestData.toSodiumPointer(
          mockSodium,
          memoryProtection: MemoryProtection.readOnly,
        );

        expect(ptr.sodium, mockSodium);
        expect(ptr.count, testData.length);
        expect(ptr.memoryProtection, MemoryProtection.readOnly);
        for (var i = 0; i < testData.length; ++i) {
          expect(ptr.ptr.elementAt(i).value, testData[i]);
        }
      });
    });

    group('Uint32', () {
      late SodiumPointer<Uint32> sut;

      setUp(() {
        final ptr = calloc<Uint32>(testData.length * sizeOf<Uint32>());
        ptr.asTypedList(testData.length).setAll(0, testData);
        sut = SodiumPointer.raw(mockSodium, ptr, testData.length);
      });

      test('asList returns memory view', () {
        final list = sut.asList();
        expect(list, testData);

        list[0] = 10;
        expect(sut.ptr.elementAt(0).value, 10);

        sut.ptr.elementAt(1).value = 20;
        expect(list[1], 20);
      });

      test('copyAsList returns memory copy', () {
        final list = sut.copyAsList();
        expect(list, testData);

        list[0] = 10;
        expect(sut.ptr.elementAt(0).value, 0x41);

        sut.ptr.elementAt(1).value = 20;
        expect(list[1], 0x42);
      });

      test('copies list to pointer', () {
        final typedTestData = Uint32List.fromList(testData);

        final ptr = typedTestData.toSodiumPointer(
          mockSodium,
          memoryProtection: MemoryProtection.readOnly,
        );

        expect(ptr.sodium, mockSodium);
        expect(ptr.count, testData.length);
        expect(ptr.memoryProtection, MemoryProtection.readOnly);
        for (var i = 0; i < testData.length; ++i) {
          expect(ptr.ptr.elementAt(i).value, testData[i]);
        }
      });
    });

    group('Uint64', () {
      late SodiumPointer<Uint64> sut;

      setUp(() {
        final ptr = calloc<Uint64>(testData.length * sizeOf<Uint64>());
        ptr.asTypedList(testData.length).setAll(0, testData);
        sut = SodiumPointer.raw(mockSodium, ptr, testData.length);
      });

      test('asList returns memory view', () {
        final list = sut.asList();
        expect(list, testData);

        list[0] = 10;
        expect(sut.ptr.elementAt(0).value, 10);

        sut.ptr.elementAt(1).value = 20;
        expect(list[1], 20);
      });

      test('copyAsList returns memory copy', () {
        final list = sut.copyAsList();
        expect(list, testData);

        list[0] = 10;
        expect(sut.ptr.elementAt(0).value, 0x41);

        sut.ptr.elementAt(1).value = 20;
        expect(list[1], 0x42);
      });

      test('copies list to pointer', () {
        final typedTestData = Uint64List.fromList(testData);

        final ptr = typedTestData.toSodiumPointer(
          mockSodium,
          memoryProtection: MemoryProtection.readOnly,
        );

        expect(ptr.sodium, mockSodium);
        expect(ptr.count, testData.length);
        expect(ptr.memoryProtection, MemoryProtection.readOnly);
        for (var i = 0; i < testData.length; ++i) {
          expect(ptr.ptr.elementAt(i).value, testData[i]);
        }
      });
    });

    group('Float', () {
      late SodiumPointer<Float> sut;

      setUp(() {
        final ptr = calloc<Float>(testData.length * sizeOf<Float>());
        ptr
            .asTypedList(testData.length)
            .setAll(0, testData.map((e) => e.toDouble()));
        sut = SodiumPointer.raw(mockSodium, ptr, testData.length);
      });

      test('asList returns memory view', () {
        final list = sut.asList();
        expect(list, testData);

        list[0] = 10;
        expect(sut.ptr.elementAt(0).value, 10);

        sut.ptr.elementAt(1).value = 20;
        expect(list[1], 20);
      });

      test('copyAsList returns memory copy', () {
        final list = sut.copyAsList();
        expect(list, testData);

        list[0] = 10;
        expect(sut.ptr.elementAt(0).value, 0x41);

        sut.ptr.elementAt(1).value = 20;
        expect(list[1], 0x42);
      });

      test('copies list to pointer', () {
        final typedTestData = Float32List.fromList(
          testData.map((e) => e.toDouble()).toList(),
        );

        final ptr = typedTestData.toSodiumPointer(
          mockSodium,
          memoryProtection: MemoryProtection.readOnly,
        );

        expect(ptr.sodium, mockSodium);
        expect(ptr.count, testData.length);
        expect(ptr.memoryProtection, MemoryProtection.readOnly);
        for (var i = 0; i < testData.length; ++i) {
          expect(ptr.ptr.elementAt(i).value, testData[i]);
        }
      });
    });

    group('Double', () {
      late SodiumPointer<Double> sut;

      setUp(() {
        final ptr = calloc<Double>(testData.length * sizeOf<Double>());
        ptr
            .asTypedList(testData.length)
            .setAll(0, testData.map((e) => e.toDouble()));
        sut = SodiumPointer.raw(mockSodium, ptr, testData.length);
      });

      test('asList returns memory view', () {
        final list = sut.asList();
        expect(list, testData);

        list[0] = 10;
        expect(sut.ptr.elementAt(0).value, 10);

        sut.ptr.elementAt(1).value = 20;
        expect(list[1], 20);
      });

      test('copyAsList returns memory copy', () {
        final list = sut.copyAsList();
        expect(list, testData);

        list[0] = 10;
        expect(sut.ptr.elementAt(0).value, 0x41);

        sut.ptr.elementAt(1).value = 20;
        expect(list[1], 0x42);
      });

      test('copies list to pointer', () {
        final typedTestData = Float64List.fromList(
          testData.map((e) => e.toDouble()).toList(),
        );

        final ptr = typedTestData.toSodiumPointer(
          mockSodium,
          memoryProtection: MemoryProtection.readOnly,
        );

        expect(ptr.sodium, mockSodium);
        expect(ptr.count, testData.length);
        expect(ptr.memoryProtection, MemoryProtection.readOnly);
        for (var i = 0; i < testData.length; ++i) {
          expect(ptr.ptr.elementAt(i).value, testData[i]);
        }
      });
    });
  });
}
