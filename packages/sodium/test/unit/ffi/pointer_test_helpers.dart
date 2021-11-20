import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/ffi/bindings/libsodium.ffi.dart';
import 'package:test/test.dart';

void registerPointers() {
  registerFallbackValue(nullptr);
}

void mockAllocArray(LibSodiumFFI mockSodium) {
  assert(mockSodium is Mock);
  when(() => mockSodium.sodium_allocarray(any(), any())).thenAnswer((i) {
    final totalSize =
        (i.positionalArguments[0] as int) * (i.positionalArguments[1] as int);
    return calloc<Uint8>(totalSize).cast();
  });
  when(() => mockSodium.sodium_mprotect_readwrite(any())).thenReturn(0);
  when(() => mockSodium.sodium_mprotect_readonly(any())).thenReturn(0);
  when(() => mockSodium.sodium_mprotect_noaccess(any())).thenReturn(0);
}

void mockAlloc(LibSodiumFFI mockSodium, int value) {
  assert(mockSodium is Mock);
  when(() => mockSodium.sodium_malloc(any())).thenAnswer((i) {
    final ptr = calloc<Uint64>()..value = value;
    return ptr.cast();
  });
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

  final List<int> data;

  const HasRawDataMatcher(this.data);

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
      for (var i = 0; i < data.length; ++i) {
        matchState[_stateKey] = 'has different value at index $i';
        expect(ptr.elementAt(i).value, data[i]);
        matchState.remove(_stateKey);
      }

      return true;
    } catch (e) {
      printOnFailure('HasRawDataMatcher failed with: $e');
      return false;
    }
  }
}

Matcher hasRawData<T extends NativeType>(List<int> data) =>
    HasRawDataMatcher<T>(data);
