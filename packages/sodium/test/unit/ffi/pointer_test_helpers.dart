import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/ffi/bindings/libsodium.ffi.dart';
import 'package:test/test.dart';

void registerPointers() {
  registerFallbackValue<Pointer<Void>>(nullptr.cast());
  registerFallbackValue<Pointer<Uint8>>(nullptr.cast());
  registerFallbackValue<Pointer<Int8>>(nullptr.cast());
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

class HasRawDataMatcher<T extends NativeType> extends Matcher {
  final List<int> data;

  const HasRawDataMatcher(this.data);

  @override
  Description describe(Description description) =>
      description.add('matches data');

  @override
  bool matches(dynamic item, Map matchState) {
    expect(item, isA<Pointer<T>>());
    final ptr = (item as Pointer<T>).cast<Uint8>();

    for (var i = 0; i < data.length; ++i) {
      expect(ptr.elementAt(i).value, data[i]);
    }

    return true;
  }
}

Matcher hasRawData(List<int> data) => HasRawDataMatcher(data);
