import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/ffi/bindings/libsodium.ffi.dart';
import 'package:sodium/src/ffi/bindings/sodium_finalizer.dart';
import 'package:sodium/src/ffi/bindings/sodium_pointer.dart';
import 'package:test/test.dart';

class MockSodiumFinalizer extends Mock implements SodiumFinalizer {}

class FakeFinalizable extends Fake implements Finalizable {}

void registerPointers() {
  registerFallbackValue(nullptr);
  registerFallbackValue(FakeFinalizable());
}

void mockAllocArray(LibSodiumFFI mockSodium) {
  // ignore: prefer_asserts_with_message
  assert(mockSodium is Mock);
  when(() => mockSodium.sodium_allocarray(any(), any())).thenAnswer((i) {
    final totalSize =
        (i.positionalArguments[0] as int) * (i.positionalArguments[1] as int);
    return calloc<Uint8>(totalSize).cast();
  });
  when(() => mockSodium.sodium_mprotect_readwrite(any())).thenReturn(0);
  when(() => mockSodium.sodium_mprotect_readonly(any())).thenReturn(0);
  when(() => mockSodium.sodium_mprotect_noaccess(any())).thenReturn(0);
  SodiumPointer.debugOverwriteFinalizer(mockSodium, MockSodiumFinalizer());
}

void mockAlloc(LibSodiumFFI mockSodium, int value) {
  // ignore: prefer_asserts_with_message
  assert(mockSodium is Mock);
  when(() => mockSodium.sodium_malloc(any())).thenAnswer((i) {
    final ptr = calloc<Uint64>()..value = value;
    return ptr.cast();
  });
  when(() => mockSodium.sodium_freePtr).thenReturn(nullptr);
  SodiumPointer.debugOverwriteFinalizer(mockSodium, MockSodiumFinalizer());
}

void fillPointer<T extends NativeType>(Pointer<T> ptr, List<int> data) {
  ptr.cast<Uint8>().asTypedList(data.length).setAll(0, data);
}

extension ListToPtrX on List<int> {
  Pointer<Uint8> toPointer() {
    final ptr = calloc<Uint8>(length);
    ptr.asTypedList(length).setAll(0, this);
    return ptr;
  }
}

class HasRawDataMatcher<T extends NativeType> extends Matcher {
  static const _stateKey = 'HasRawDataMatcher_state_key';

  final List<num> data;
  final int? sizeHint;

  const HasRawDataMatcher(this.data, this.sizeHint);

  @override
  Description describe(Description description) =>
      description.add('Pointer<$T> that matches ').addDescriptionOf(data);

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map matchState,
    bool verbose,
  ) {
    if (matchState.containsKey(_stateKey)) {
      return mismatchDescription.add(matchState[_stateKey].toString());
    } else {
      return mismatchDescription;
    }
  }

  @override
  bool matches(dynamic item, Map matchState) {
    try {
      expect(item, isA<Pointer<T>>());

      final ptr = (item as Pointer<T>).cast<Uint8>();
      final ptrBuffer = ptr.asTypedList(data.length * (sizeHint ?? 1)).buffer;
      final List<int> ptrList;
      switch (sizeHint) {
        case 8:
          ptrList = ptrBuffer.asUint64List();
        case 4:
          ptrList = ptrBuffer.asUint32List();
        case 2:
          ptrList = ptrBuffer.asUint16List();
        case 1:
        case null:
          ptrList = ptrBuffer.asUint8List();
        default:
          matchState[_stateKey] = 'invalid sizeHint $sizeHint';
          return false;
      }

      for (var i = 0; i < data.length; ++i) {
        matchState[_stateKey] =
            'has different value at index $i: ${ptrList[i]}';
        expect(ptrList[i], data[i]);
        matchState.remove(_stateKey);
      }

      return true;
    } catch (e) {
      printOnFailure('HasRawDataMatcher failed with: $e');
      return false;
    }
  }
}

Matcher hasRawData<T extends NativeType>(List<num> data, {int? sizeHint}) =>
    HasRawDataMatcher<T>(data, sizeHint);
