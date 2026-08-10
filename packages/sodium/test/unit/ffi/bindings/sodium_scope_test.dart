// ignore_for_file: unnecessary_lambdas for mocking

@TestOn('dart-vm')
library;

import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:dart_test_tools/test.dart';
import 'package:ffi/ffi.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/ffi/api/secure_key_ffi.dart';
import 'package:sodium/src/ffi/bindings/libsodium.ffi.wrapper.dart';
import 'package:sodium/src/ffi/bindings/memory_protection.dart';
import 'package:sodium/src/ffi/bindings/sodium_pointer.dart';
import 'package:sodium/src/ffi/bindings/sodium_scope.dart';
import 'package:test/test.dart';

import '../pointer_test_helpers.dart';

class MockSodiumFFI extends Mock implements LibSodiumFFI {}

void main() {
  final mockSodium = MockSodiumFFI();

  setUpAll(() {
    registerPointers();
  });

  setUp(() {
    reset(mockSodium);
    mockAllocArray(mockSodium);
  });

  // Makes disposing the pointer at [address] fail with [error], while still
  // releasing the test memory behind it.
  void failFreeOf(int address, Exception error) {
    when(
      () => mockSodium.sodium_free(any(that: hasAddress(address))),
    ).thenAnswer((i) {
      calloc.free(i.positionalArguments.first as Pointer);
      throw error;
    });
  }

  group('sodiumScope', () {
    test('returns the value produced by the body', () {
      final result = sodiumScope(mockSodium, (scope) => 42);

      expect(result, 42);
    });

    test('provides a scope instance to the body', () {
      sodiumScope(mockSodium, (scope) {
        expect(scope, isA<SodiumScope>());
      });
    });

    test('frees nothing when the body allocates nothing', () {
      sodiumScope(mockSodium, (scope) {});

      verifyNever(() => mockSodium.sodium_free(any()));
    });

    test('frees every tracked allocation after the body returns', () {
      sodiumScope(mockSodium, (scope) {
        scope
          ..alloc<UnsignedChar>(8)
          ..allocSecureKey(24)
          ..copyList<UnsignedChar>(Uint8List.fromList([1, 2, 3]))
          ..copyString('abc');
      });

      verify(() => mockSodium.sodium_free(any())).called(4);
    });

    test('frees every tracked allocation when the body throws', () {
      final error = Exception('boom');

      expect(
        () => sodiumScope(mockSodium, (scope) {
          scope
            ..alloc<UnsignedChar>(8)
            ..allocSecureKey(24)
            ..copyList<UnsignedChar>(Uint8List.fromList([1, 2, 3]))
            ..copyString('abc');
          throw error;
        }),
        throwsA(same(error)),
      );

      verify(() => mockSodium.sodium_free(any())).called(4);
    });

    test('keeps freeing after a dispose failure and reports the error', () {
      final disposeError = Exception('cannot free');
      final reportedErrors = <Object>[];

      final result = runZonedGuarded(
        () => sodiumScope(mockSodium, (scope) {
          scope
            ..alloc<UnsignedChar>(2)
            ..alloc<UnsignedChar>(2);
          // The last allocation is disposed first (LIFO) - make that one fail.
          final failing = scope.alloc<UnsignedChar>(2);
          failFreeOf(failing.ptr.address, disposeError);
          return 42;
        }),
        (error, stackTrace) => reportedErrors.add(error),
      );

      // the failure neither breaks the result nor the remaining disposals
      expect(result, 42);
      verify(() => mockSodium.sodium_free(any())).called(3);
      expect(reportedErrors, [same(disposeError)]);
    });

    test('reports dispose failures without masking the body error', () {
      final bodyError = SodiumException();
      final disposeError = Exception('cannot free');
      final reportedErrors = <Object>[];

      runZonedGuarded(
        () => expect(
          () => sodiumScope(mockSodium, (scope) {
            scope
              ..alloc<UnsignedChar>(2)
              ..alloc<UnsignedChar>(2);
            final failing = scope.alloc<UnsignedChar>(2);
            failFreeOf(failing.ptr.address, disposeError);
            throw bodyError;
          }),
          throwsA(same(bodyError)),
        ),
        (error, stackTrace) => reportedErrors.add(error),
      );

      verify(() => mockSodium.sodium_free(any())).called(3);
      expect(reportedErrors, [same(disposeError)]);
    });
  });

  group('copyList', () {
    test('allocates a pointer holding a copy of the data', () {
      final data = List.generate(6, (i) => i * 3);

      sodiumScope(mockSodium, (scope) {
        final ptr = scope.copyList<UnsignedChar>(Uint8List.fromList(data));

        expect(ptr, isA<SodiumPointer<UnsignedChar>>());
        expect(ptr.count, data.length);
        expect(ptr.ptr, hasRawData<UnsignedChar>(data));
      });
    });

    test('applies readOnly protection by default', () {
      late int addr;

      sodiumScope(mockSodium, (scope) {
        addr = scope
            .copyList<UnsignedChar>(Uint8List.fromList([1, 2, 3]))
            .ptr
            .address;
      });

      verify(
        () => mockSodium.sodium_mprotect_readonly(any(that: hasAddress(addr))),
      );
    });

    test('applies a custom memory protection', () {
      late int addr;
      sodiumScope(mockSodium, (scope) {
        addr = scope
            .copyList<UnsignedChar>(
              Uint8List.fromList([1, 2, 3]),
              memoryProtection: .noAccess,
            )
            .ptr
            .address;
      });

      verifyNever(() => mockSodium.sodium_mprotect_readonly(any()));
      verify(
        () => mockSodium.sodium_mprotect_noaccess(any(that: hasAddress(addr))),
      );
    });

    test('frees the pointer at scope exit', () {
      late int addr;
      sodiumScope(mockSodium, (scope) {
        addr = scope
            .copyList<UnsignedChar>(Uint8List.fromList([1, 2, 3]))
            .ptr
            .address;
      });

      verify(
        () => mockSodium.sodium_free(any(that: hasAddress(addr))),
      ).called(1);
    });

    test('can copy larger integer types', () {
      final data = [10, 20, 30];

      sodiumScope(mockSodium, (scope) {
        final ptr = scope.copyList<UnsignedLongLong>(Uint64List.fromList(data));

        expect(ptr.count, data.length);
        expect(ptr.ptr, hasRawData<UnsignedLongLong>(data, sizeHint: 8));
      });

      verify(
        () => mockSodium.sodium_allocarray(
          data.length,
          sizeOf<UnsignedLongLong>(),
        ),
      );
    });
  });

  group('copyString', () {
    test('allocates a char pointer with the string bytes', () {
      sodiumScope(mockSodium, (scope) {
        final ptr = scope.copyString('abc');

        expect(ptr, isA<SodiumPointer<Char>>());
        expect(ptr.count, 3);
        expect(ptr.ptr, hasRawData<Char>([97, 98, 99]));
      });
    });

    test('pads to memoryWidth and zero-fills the remainder', () {
      sodiumScope(mockSodium, (scope) {
        final ptr = scope.copyString('ab', memoryWidth: 5);

        expect(ptr.count, 5);
        expect(ptr.ptr, hasRawData<Char>([97, 98, 0, 0, 0]));
      });
    });

    test('stops at the first zero when zeroTerminated', () {
      sodiumScope(mockSodium, (scope) {
        final ptr = scope.copyString('ab\x00c', zeroTerminated: true);

        expect(ptr.count, 2);
        expect(ptr.ptr, hasRawData<Char>([97, 98]));
      });
    });

    test('encodes with the given encoding', () {
      sodiumScope(mockSodium, (scope) {
        final ptr = scope.copyString('äb', encoding: latin1);

        expect(ptr.count, 2);
        expect(ptr.ptr, hasRawData<Char>([0xE4, 98]));
      });
    });

    test('applies readOnly protection by default', () {
      late int addr;

      sodiumScope(mockSodium, (scope) {
        addr = scope.copyString('abc').ptr.address;
      });

      verify(
        () => mockSodium.sodium_mprotect_readonly(any(that: hasAddress(addr))),
      );
    });

    test('applies custom memory protection when specified', () {
      late int addr;

      sodiumScope(mockSodium, (scope) {
        addr = scope.copyString('abc', memoryProtection: .noAccess).ptr.address;
      });

      verify(
        () => mockSodium.sodium_mprotect_noaccess(any(that: hasAddress(addr))),
      );
    });

    test('frees the pointer at scope exit', () {
      late int addr;
      sodiumScope(mockSodium, (scope) {
        addr = scope.copyString('abc').ptr.address;
      });

      verify(
        () => mockSodium.sodium_free(any(that: hasAddress(addr))),
      ).called(1);
    });
  });

  group('alloc', () {
    test('allocates an empty buffer of count elements', () {
      sodiumScope(mockSodium, (scope) {
        final ptr = scope.alloc<UnsignedChar>(16);

        expect(ptr, isA<SodiumPointer<UnsignedChar>>());
        expect(ptr.count, 16);
      });

      verify(() => mockSodium.sodium_allocarray(16, 1));
      verifyNever(() => mockSodium.sodium_memzero(any(), any()));
    });

    test('can allocate larger integers', () {
      sodiumScope(mockSodium, (scope) {
        final ptr = scope.alloc<UnsignedLongLong>(16);

        expect(ptr, isA<SodiumPointer<UnsignedLongLong>>());
        expect(ptr.count, 16);
      });

      verify(
        () => mockSodium.sodium_allocarray(16, sizeOf<UnsignedLongLong>()),
      );
    });

    test('applies readWrite protection by default', () {
      sodiumScope(mockSodium, (scope) {
        scope.alloc<UnsignedChar>(4);
      });

      verifyNever(() => mockSodium.sodium_mprotect_readonly(any()));
      verifyNever(() => mockSodium.sodium_mprotect_noaccess(any()));
    });

    test('uses different memory protection when requested', () {
      late int addr;

      sodiumScope(mockSodium, (scope) {
        addr = scope
            .alloc<UnsignedChar>(4, memoryProtection: .readOnly)
            .ptr
            .address;
      });

      verify(
        () => mockSodium.sodium_mprotect_readonly(any(that: hasAddress(addr))),
      );
    });

    test('zeroes the memory when requested', () {
      late int addr;

      sodiumScope(mockSodium, (scope) {
        addr = scope.alloc<UnsignedChar>(4, zeroMemory: true).ptr.address;
      });

      verify(() => mockSodium.sodium_memzero(any(that: hasAddress(addr)), 4));
    });

    test('returns a usable pointer supporting fill and viewAt', () {
      sodiumScope(mockSodium, (scope) {
        final ptr = scope.alloc<UnsignedChar>(4)..fill([10, 20], offset: 1);

        expect(ptr.asListView<Uint8List>(), [0, 10, 20, 0]);
        expect(ptr.viewAt(1).ptr, hasRawData<UnsignedChar>([10, 20, 0]));
      });
    });

    test('frees the buffer at scope exit', () {
      late int addr;
      sodiumScope(mockSodium, (scope) {
        addr = scope.alloc<UnsignedChar>(8).ptr.address;
      });

      verify(
        () => mockSodium.sodium_free(any(that: hasAddress(addr))),
      ).called(1);
    });
  });

  group('allocSecureKey', () {
    test('allocates a secure key of the requested length', () {
      sodiumScope(mockSodium, (scope) {
        final key = scope.allocSecureKey(24);

        expect(key, isA<SecureKeyFFI>());
        expect(key.length, 24);
      });

      verify(() => mockSodium.sodium_allocarray(24, 1));
    });

    test('frees the key at scope exit', () {
      sodiumScope(mockSodium, (scope) {
        scope.allocSecureKey(24);
      });

      verify(() => mockSodium.sodium_free(any())).called(1);
    });
  });

  group('takeBytes', () {
    test('returns a list view of the pointer data', () {
      final data = List.generate(5, (i) => 40 + i);

      final result = sodiumScope(mockSodium, (scope) {
        final ptr = scope.alloc<UnsignedChar>(5)..fill(data);
        return scope.takeBytes<Uint8List>(ptr);
      });

      expect(result, isA<Uint8List>());
      expect(result, data);
    });

    test('transfers ownership so the pointer is not freed at scope exit', () {
      late int takenAddr;
      late int trackedAddr;

      sodiumScope(mockSodium, (scope) {
        final taken = scope.alloc<UnsignedChar>(4);
        final tracked = scope.copyList<UnsignedChar>(
          Uint8List.fromList([9, 9]),
        );
        takenAddr = taken.ptr.address;
        trackedAddr = tracked.ptr.address;
        scope.takeBytes<Uint8List>(taken);
      });

      // Only the still-tracked input is freed; the handed-off buffer is not.
      verify(
        () => mockSodium.sodium_free(any(that: hasAddress(trackedAddr))),
      ).called(1);
      verifyNever(
        () => mockSodium.sodium_free(any(that: hasAddress(takenAddr))),
      );
    });

    test('keeps the pointer tracked if asListView throws', () {
      // Handing ownership over flips the buffer to readWrite first; make that
      // fail so takeBytes throws before it detaches / untracks the pointer.
      when(() => mockSodium.sodium_mprotect_readwrite(any())).thenReturn(1);

      late int addr;

      expect(
        () => sodiumScope(mockSodium, (scope) {
          // copyList => readOnly, so the take actually toggles to readWrite.
          final ptr = scope.copyList<UnsignedChar>(
            Uint8List.fromList([1, 2, 3]),
          );
          addr = ptr.ptr.address;
          return scope.takeBytes<Uint8List>(ptr);
        }),
        throwsA(isA<SodiumException>()),
      );

      // Still tracked => the scope frees it on the way out.
      verify(
        () => mockSodium.sodium_free(any(that: hasAddress(addr))),
      ).called(1);
    });

    test('throws when handed a view of a tracked pointer', () {
      late int addr;

      expect(
        () => sodiumScope(mockSodium, (scope) {
          // alloc is readWrite already, so only the detach of the view fails
          final ptr = scope.alloc<UnsignedChar>(4);
          addr = ptr.ptr.address;
          return scope.takeBytes<Uint8List>(ptr.viewAt(1));
        }),
        throwsUnsupportedError,
      );

      // the parent was never untracked and is still freed exactly once
      verify(
        () => mockSodium.sodium_free(any(that: hasAddress(addr))),
      ).called(1);
    });

    test('asserts when handed a pointer the scope does not own', () {
      final foreign = SodiumPointer<UnsignedChar>.alloc(mockSodium, count: 2);

      expect(
        () => sodiumScope(
          mockSodium,
          (scope) => scope.takeBytes<Uint8List>(foreign),
        ),
        throwsA(isA<AssertionError>()),
      );

      // takeBytes detached it before the assert - dispose is a noop now
      verifyNever(() => mockSodium.sodium_free(any()));
      calloc.free(foreign.ptr);
    });
  });

  group('takeString', () {
    test('converts the pointer to a dart string', () {
      final result = sodiumScope(
        mockSodium,
        (scope) => scope.takeString(scope.copyString('hello')),
      );

      expect(result, 'hello');
    });

    test('frees the pointer immediately and never again', () {
      var freeCount = 0;
      when(() => mockSodium.sodium_free(any())).thenAnswer((i) {
        freeCount++;
        calloc.free(i.positionalArguments.first as Pointer);
      });

      sodiumScope(mockSodium, (scope) {
        final ptr = scope.copyString('hello');

        expect(freeCount, 0);
        scope.takeString(ptr);
        // freed right away, not deferred to scope exit
        expect(freeCount, 1);
      });

      // no double free when the scope unwinds
      expect(freeCount, 1);
    });

    testData(
      'honors zeroTerminated when decoding',
      [(true, 'ab'), (false, 'ab\x00\x00\x00')],
      (fixture) {
        final result = sodiumScope(
          mockSodium,
          (scope) => scope.takeString(
            scope.copyString('ab', memoryWidth: 5),
            zeroTerminated: fixture.$1,
          ),
        );

        expect(result, fixture.$2);
      },
    );

    test('decodes with the given encoding', () {
      final result = sodiumScope(
        mockSodium,
        (scope) => scope.takeString(
          scope.copyString('äb', encoding: latin1),
          encoding: latin1,
        ),
      );

      expect(result, 'äb');
    });

    test('keeps the pointer tracked if decoding throws', () {
      late int addr;

      expect(
        () => sodiumScope(mockSodium, (scope) {
          // 0xFF is not valid utf8, so the decoding fails
          final ptr = scope.alloc<Char>(2)..fill([-1, -1]);
          addr = ptr.ptr.address;
          return scope.takeString(ptr);
        }),
        throwsFormatException,
      );

      // Still tracked => the scope frees it on the way out.
      verify(
        () => mockSodium.sodium_free(any(that: hasAddress(addr))),
      ).called(1);
    });

    test('asserts when handed a view of a tracked pointer', () {
      late int addr;

      expect(
        () => sodiumScope(mockSodium, (scope) {
          final ptr = scope.copyString('abcd');
          addr = ptr.ptr.address;
          return scope.takeString(ptr.viewAt(1));
        }),
        throwsA(isA<AssertionError>()),
      );

      // the parent was never untracked and is still freed exactly once
      verify(
        () => mockSodium.sodium_free(any(that: hasAddress(addr))),
      ).called(1);
    });
  });

  group('takeSecureKey', () {
    test('returns the same key instance', () {
      late SecureKeyFFI allocated;

      final taken = sodiumScope(mockSodium, (scope) {
        allocated = scope.allocSecureKey(8);
        return scope.takeSecureKey(allocated);
      });

      expect(taken, same(allocated));
    });

    test('does not free the taken key at scope exit', () {
      final taken = sodiumScope(
        mockSodium,
        (scope) => scope.takeSecureKey(scope.allocSecureKey(8)),
      );

      verifyNever(() => mockSodium.sodium_free(any()));

      // the caller now owns it; disposing frees exactly once
      taken.dispose();
      verify(() => mockSodium.sodium_free(any())).called(1);
    });

    test('asserts when handed a key the scope does not own', () {
      final foreign = SecureKeyFFI.alloc(mockSodium, 8);

      expect(
        () => sodiumScope(mockSodium, (scope) => scope.takeSecureKey(foreign)),
        throwsA(isA<AssertionError>()),
      );

      verifyNever(() => mockSodium.sodium_free(any()));

      foreign.dispose();
      verify(() => mockSodium.sodium_free(any())).called(1);
    });
  });

  group('takePointer', () {
    test('returns the same pointer instance', () {
      late SodiumPointer<UnsignedChar> allocated;

      final taken = sodiumScope(mockSodium, (scope) {
        allocated = scope.alloc<UnsignedChar>(4);
        return scope.takePointer(allocated);
      });

      expect(taken, same(allocated));

      taken.dispose();
    });

    test('keeps the pointer usable, with its memory protection intact', () {
      final taken = sodiumScope(
        mockSodium,
        (scope) => scope.takePointer(
          scope.copyList<UnsignedChar>(Uint8List.fromList([1, 2, 3])),
        ),
      );

      expect(taken.memoryProtection, MemoryProtection.readOnly);
      expect(taken.asListView<Uint8List>(), [1, 2, 3]);

      taken.dispose();
    });

    test('does not free the taken pointer at scope exit', () {
      final taken = sodiumScope(
        mockSodium,
        (scope) => scope.takePointer(scope.alloc<UnsignedChar>(4)),
      );

      verifyNever(() => mockSodium.sodium_free(any()));

      // the caller now owns it; disposing frees exactly once
      taken.dispose();
      verify(() => mockSodium.sodium_free(any())).called(1);
    });

    test('only untracks the taken pointer', () {
      late int takenAddr;
      late int trackedAddr;

      final taken = sodiumScope(mockSodium, (scope) {
        final tracked = scope.copyList<UnsignedChar>(
          Uint8List.fromList([9, 9]),
        );
        final toTake = scope.alloc<UnsignedChar>(4);
        trackedAddr = tracked.ptr.address;
        takenAddr = toTake.ptr.address;
        return scope.takePointer(toTake);
      });

      verify(
        () => mockSodium.sodium_free(any(that: hasAddress(trackedAddr))),
      ).called(1);
      verifyNever(
        () => mockSodium.sodium_free(any(that: hasAddress(takenAddr))),
      );

      taken.dispose();
    });

    test('asserts when handed a pointer the scope does not own', () {
      final foreign = SodiumPointer<UnsignedChar>.alloc(mockSodium, count: 2);

      expect(
        () => sodiumScope(mockSodium, (scope) => scope.takePointer(foreign)),
        throwsA(isA<AssertionError>()),
      );

      verifyNever(() => mockSodium.sodium_free(any()));

      foreign.dispose();
      verify(() => mockSodium.sodium_free(any())).called(1);
    });

    test('asserts when handed a view of a tracked pointer', () {
      late int addr;

      expect(
        () => sodiumScope(mockSodium, (scope) {
          final ptr = scope.alloc<UnsignedChar>(4);
          addr = ptr.ptr.address;
          return scope.takePointer(ptr.viewAt(1));
        }),
        throwsA(isA<AssertionError>()),
      );

      // the parent was never untracked and is still freed exactly once
      verify(
        () => mockSodium.sodium_free(any(that: hasAddress(addr))),
      ).called(1);
    });
  });

  group('ownership integration', () {
    test('success path: inputs freed, taken outputs survive', () {
      late int nonceAddr;

      final result = sodiumScope(mockSodium, (scope) {
        final dataPtr = scope.alloc<UnsignedChar>(4)..fill([1, 2, 3, 4]);
        final macPtr = scope.alloc<UnsignedChar>(2)..fill([5, 6]);
        final noncePtr = scope.copyList<UnsignedChar>(
          Uint8List.fromList([7, 8]),
        );
        nonceAddr = noncePtr.ptr.address;

        return (
          data: scope.takeBytes<Uint8List>(dataPtr),
          mac: scope.takeBytes<Uint8List>(macPtr),
        );
      });

      expect(result.data, [1, 2, 3, 4]);
      expect(result.mac, [5, 6]);

      verify(
        () => mockSodium.sodium_free(any(that: hasAddress(nonceAddr))),
      ).called(1);
      verifyNever(() => mockSodium.sodium_free(any()));
    });

    test('error path: inputs and not-yet-taken outputs are all freed', () {
      expect(
        () => sodiumScope(mockSodium, (scope) {
          scope
            ..alloc<UnsignedChar>(4)
            ..alloc<UnsignedChar>(2)
            ..copyList<UnsignedChar>(Uint8List.fromList([7, 8]));
          throw SodiumException();
        }),
        throwsA(isA<SodiumException>()),
      );

      verify(() => mockSodium.sodium_free(any())).called(3);
    });
  });
}
