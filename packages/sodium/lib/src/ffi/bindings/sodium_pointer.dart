import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import 'libsodium.ffi.dart';

enum MemoryProtection {
  noAccess,
  readOnly,
  readWrite,
}

class SodiumPointer<T extends NativeType> with _StaticallyTypedSizeOf {
  final LibSodiumFFI sodium;
  final Pointer<T> ptr;
  final int count;

  bool _locked = true;
  MemoryProtection _memoryProtection = MemoryProtection.readWrite;

  SodiumPointer.raw(this.sodium, this.ptr, this.count);

  factory SodiumPointer.alloc(
    LibSodiumFFI sodium, {
    int count = 1,
    MemoryProtection memoryProtection = MemoryProtection.readWrite,
    bool zeroMemory = false,
  }) {
    RangeError.checkNotNegative(count, 'count', 'must not be negative');

    final elementSize = _StaticallyTypedSizeOf.staticSizeOf<T>();
    late final SodiumPointer<T> ptr;
    if (count != 1) {
      ptr = SodiumPointer.raw(
        sodium,
        sodium.sodium_allocarray(count, elementSize).cast(),
        count,
      );
    } else {
      ptr = SodiumPointer.raw(
        sodium,
        sodium.sodium_malloc(elementSize).cast(),
        1,
      );
    }

    try {
      if (zeroMemory) {
        ptr.zeroMemory();
      }
      ptr.memoryProtection = memoryProtection;
      return ptr;
    } catch (e) {
      ptr.dispose();
      rethrow;
    }
  }

  factory SodiumPointer.fromList(
    LibSodiumFFI sodium,
    List<num> list, {
    MemoryProtection memoryProtection = MemoryProtection.readWrite,
  }) {
    final typeLen = _StaticallyTypedSizeOf.staticSizeOf<T>();
    final sodiumPtr = SodiumPointer.raw(
      sodium,
      sodium.sodium_allocarray(list.length, typeLen).cast<T>(),
      list.length * typeLen,
    );
    try {
      sodiumPtr._asTypedIntListRaw().setAll(0, list);
      sodiumPtr.memoryProtection = memoryProtection;
      return sodiumPtr;
    } catch (e) {
      sodiumPtr.dispose();
      rethrow;
    }
  }

  int get elementSize => _StaticallyTypedSizeOf.staticSizeOf<T>();

  int get byteLength => count * elementSize;

  bool get locked => _locked;

  set locked(bool locked) {
    if (locked == _locked) {
      return;
    }

    if (locked) {
      sodium.sodium_mlock(ptr.cast(), byteLength);
    } else {
      sodium.sodium_munlock(ptr.cast(), byteLength);
    }

    _locked = locked;
  }

  MemoryProtection get memoryProtection => _memoryProtection;

  set memoryProtection(MemoryProtection memoryProtection) {
    if (memoryProtection == _memoryProtection) {
      return;
    }

    switch (memoryProtection) {
      case MemoryProtection.noAccess:
        sodium.sodium_mprotect_noaccess(ptr.cast());
        break;
      case MemoryProtection.readOnly:
        sodium.sodium_mprotect_readonly(ptr.cast());
        break;
      case MemoryProtection.readWrite:
        sodium.sodium_mprotect_readwrite(ptr.cast());
        break;
    }
    _memoryProtection = memoryProtection;
  }

  void zeroMemory() => sodium.sodium_memzero(ptr.cast(), byteLength);

  void dispose() {
    try {
      memoryProtection = MemoryProtection.readWrite;
      zeroMemory();
    } finally {
      sodium.sodium_free(ptr.cast());
    }
  }

  List<num> _asTypedIntListRaw() {
    switch (T) {
      case Int8:
        return (this as SodiumPointer<Int8>).asList();
      case Int16:
        return (this as SodiumPointer<Int16>).asList();
      case Int32:
        return (this as SodiumPointer<Int32>).asList();
      case Int64:
        return (this as SodiumPointer<Int64>).asList();
      case Uint8:
        return (this as SodiumPointer<Uint8>).asList();
      case Uint16:
        return (this as SodiumPointer<Uint16>).asList();
      case Uint32:
        return (this as SodiumPointer<Uint32>).asList();
      case Uint64:
        return (this as SodiumPointer<Uint64>).asList();
      case Float:
        return (this as SodiumPointer<Float>).asList();
      case Double:
        return (this as SodiumPointer<Double>).asList();
      default:
        throw UnsupportedError(
          'Cannot create a SodiumPointer<$T> from a List<num>',
        );
    }
  }
}

extension StringPtr on Pointer<Int8> {
  String toDartString() => cast<Utf8>().toDartString();
}

extension Int8SodiumPtr on SodiumPointer<Int8> {
  Int8List asList() => ptr.asTypedList(count);

  Int8List copyAsList() => Int8List.fromList(asList());

  String toDartString() => ptr.toDartString();
}

extension Int16SodiumPtr on SodiumPointer<Int16> {
  Int16List asList() => ptr.asTypedList(count);

  Int16List copyAsList() => Int16List.fromList(asList());
}

extension Int32SodiumPtr on SodiumPointer<Int32> {
  Int32List asList() => ptr.asTypedList(count);

  Int32List copyAsList() => Int32List.fromList(asList());
}

extension Int64SodiumPtr on SodiumPointer<Int64> {
  Int64List asList() => ptr.asTypedList(count);

  Int64List copyAsList() => Int64List.fromList(asList());
}

extension Uint8SodiumPtr on SodiumPointer<Uint8> {
  Uint8List asList() => ptr.asTypedList(count);

  Uint8List copyAsList() => Uint8List.fromList(asList());
}

extension Uint16SodiumPtr on SodiumPointer<Uint16> {
  Uint16List asList() => ptr.asTypedList(count);

  Uint16List copyAsList() => Uint16List.fromList(asList());
}

extension Uint32SodiumPtr on SodiumPointer<Uint32> {
  Uint32List asList() => ptr.asTypedList(count);

  Uint32List copyAsList() => Uint32List.fromList(asList());
}

extension Uint64SodiumPtr on SodiumPointer<Uint64> {
  Uint64List asList() => ptr.asTypedList(count);

  Uint64List copyAsList() => Uint64List.fromList(asList());
}

extension FloatSodiumPtr on SodiumPointer<Float> {
  Float32List asList() => ptr.asTypedList(count);

  Float32List copyAsList() => Float32List.fromList(asList());
}

extension DoubleSodiumPtr on SodiumPointer<Double> {
  Float64List asList() => ptr.asTypedList(count);

  Float64List copyAsList() => Float64List.fromList(asList());
}

abstract class _StaticallyTypedSizeOf {
  static int staticSizeOf<T>() {
    switch (T) {
      case Int8:
        return sizeOf<Int8>();
      case Int16:
        return sizeOf<Int16>();
      case Int32:
        return sizeOf<Int32>();
      case Int64:
        return sizeOf<Int64>();
      case Uint8:
        return sizeOf<Uint8>();
      case Uint16:
        return sizeOf<Uint16>();
      case Uint32:
        return sizeOf<Uint32>();
      case Uint64:
        return sizeOf<Uint64>();
      case Float:
        return sizeOf<Float>();
      case Double:
        return sizeOf<Double>();
      default:
        throw UnsupportedError(
          'Cannot create a SodiumPointer for $T. T must be a primitive type',
        );
    }
  }
}
