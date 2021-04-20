import 'dart:ffi';
import 'dart:typed_data';

import 'package:meta/meta.dart';
import '../../api/sodium_exception.dart';
import '../../api/string_x.dart';

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
  final bool _isView;

  bool _locked;
  MemoryProtection _memoryProtection;

  SodiumPointer.raw(this.sodium, this.ptr, this.count)
      : _isView = false,
        _locked = true,
        _memoryProtection = MemoryProtection.readWrite;

  factory SodiumPointer.alloc(
    LibSodiumFFI sodium, {
    int count = 1,
    MemoryProtection memoryProtection = MemoryProtection.readWrite,
    bool zeroMemory = false,
  }) {
    RangeError.checkNotNegative(count, 'count');

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

  @visibleForTesting
  factory SodiumPointer.fromList(
    LibSodiumFFI sodium,
    List<num> list, {
    MemoryProtection memoryProtection = MemoryProtection.readWrite,
  }) {
    final count = list.length;
    final typeLen = _StaticallyTypedSizeOf.staticSizeOf<T>();
    final sodiumPtr = SodiumPointer.raw(
      sodium,
      sodium.sodium_allocarray(count, typeLen).cast<T>(),
      count,
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

  SodiumPointer._view(
    this.sodium,
    this.ptr,
    this.count,
    this._locked,
    this._memoryProtection,
  ) : _isView = true;

  int get elementSize => _StaticallyTypedSizeOf.staticSizeOf<T>();

  int get byteLength => count * elementSize;

  bool get locked => _locked;

  set locked(bool locked) {
    if (locked == _locked) {
      return;
    }

    late int result;
    if (locked) {
      result = sodium.sodium_mlock(ptr.cast(), byteLength);
    } else {
      result = sodium.sodium_munlock(ptr.cast(), byteLength);
    }
    SodiumException.checkSucceededInt(result);

    _locked = locked;
  }

  MemoryProtection get memoryProtection => _memoryProtection;

  set memoryProtection(MemoryProtection memoryProtection) {
    if (memoryProtection == _memoryProtection) {
      return;
    }

    late int result;
    switch (memoryProtection) {
      case MemoryProtection.noAccess:
        result = sodium.sodium_mprotect_noaccess(ptr.cast());
        break;
      case MemoryProtection.readOnly:
        result = sodium.sodium_mprotect_readonly(ptr.cast());
        break;
      case MemoryProtection.readWrite:
        result = sodium.sodium_mprotect_readwrite(ptr.cast());
        break;
    }
    SodiumException.checkSucceededInt(result);

    _memoryProtection = memoryProtection;
  }

  void zeroMemory() => sodium.sodium_memzero(ptr.cast(), byteLength);

  SodiumPointer<T> viewAt(int offset, [int? length]) {
    if (offset > count) {
      throw ArgumentError.value(
        offset,
        'offset',
        'cannot be bigger than count ($count)',
      );
    }

    if (length != null && length > count - offset) {
      throw ArgumentError.value(
        length,
        'length',
        'cannot be bigger than count - offset (${count - offset})',
      );
    }

    return SodiumPointer._view(
      sodium,
      _elementAtRaw(offset),
      length ?? count - offset,
      _locked,
      _memoryProtection,
    );
  }

  void fill(List<num> data, {int offset = 0}) {
    if (data.length + offset > count) {
      throw ArgumentError(
        'data and offset are to long. '
        'Can at most write $count elements, '
        'but requested offset=$offset + data=${data.length}',
      );
    }
    _asTypedIntListRaw().setAll(offset, data);
  }

  void dispose() {
    if (_isView) {
      return;
    }
    sodium.sodium_free(ptr.cast());
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
        // coverage:ignore-start
        throw UnsupportedError(
          'Cannot create a SodiumPointer<$T> from a List<num>',
        );
      // coverage:ignore-end
    }
  }

  Pointer<T> _elementAtRaw(int offset) {
    switch (T) {
      case Int8:
        return (this as SodiumPointer<Int8>).ptr.elementAt(offset)
            as Pointer<T>;
      case Int16:
        return (this as SodiumPointer<Int16>).ptr.elementAt(offset)
            as Pointer<T>;
      case Int32:
        return (this as SodiumPointer<Int32>).ptr.elementAt(offset)
            as Pointer<T>;
      case Int64:
        return (this as SodiumPointer<Int64>).ptr.elementAt(offset)
            as Pointer<T>;
      case Uint8:
        return (this as SodiumPointer<Uint8>).ptr.elementAt(offset)
            as Pointer<T>;
      case Uint16:
        return (this as SodiumPointer<Uint16>).ptr.elementAt(offset)
            as Pointer<T>;
      case Uint32:
        return (this as SodiumPointer<Uint32>).ptr.elementAt(offset)
            as Pointer<T>;
      case Uint64:
        return (this as SodiumPointer<Uint64>).ptr.elementAt(offset)
            as Pointer<T>;
      case Float:
        return (this as SodiumPointer<Float>).ptr.elementAt(offset)
            as Pointer<T>;
      case Double:
        return (this as SodiumPointer<Double>).ptr.elementAt(offset)
            as Pointer<T>;
      default:
        // coverage:ignore-start
        throw UnsupportedError(
          'Cannot get offset for a SodiumPointer<$T>',
        );
      // coverage:ignore-end
    }
  }
}

extension Int8SodiumPtr on SodiumPointer<Int8> {
  Int8List asList([int? length]) => ptr.asTypedList(length ?? count);

  Int8List copyAsList([int? length]) => Int8List.fromList(asList(length));

  String toDartString({bool zeroTerminated = false}) =>
      asList().toDartString(zeroTerminated: zeroTerminated);
}

extension Int16SodiumPtr on SodiumPointer<Int16> {
  Int16List asList([int? length]) => ptr.asTypedList(length ?? count);

  Int16List copyAsList([int? length]) => Int16List.fromList(asList(length));
}

extension Int32SodiumPtr on SodiumPointer<Int32> {
  Int32List asList([int? length]) => ptr.asTypedList(length ?? count);

  Int32List copyAsList([int? length]) => Int32List.fromList(asList(length));
}

extension Int64SodiumPtr on SodiumPointer<Int64> {
  Int64List asList([int? length]) => ptr.asTypedList(length ?? count);

  Int64List copyAsList([int? length]) => Int64List.fromList(asList(length));
}

extension Uint8SodiumPtr on SodiumPointer<Uint8> {
  Uint8List asList([int? length]) => ptr.asTypedList(length ?? count);

  Uint8List copyAsList([int? length]) => Uint8List.fromList(asList(length));
}

extension Uint16SodiumPtr on SodiumPointer<Uint16> {
  Uint16List asList([int? length]) => ptr.asTypedList(length ?? count);

  Uint16List copyAsList([int? length]) => Uint16List.fromList(asList(length));
}

extension Uint32SodiumPtr on SodiumPointer<Uint32> {
  Uint32List asList([int? length]) => ptr.asTypedList(length ?? count);

  Uint32List copyAsList([int? length]) => Uint32List.fromList(asList(length));
}

extension Uint64SodiumPtr on SodiumPointer<Uint64> {
  Uint64List asList([int? length]) => ptr.asTypedList(length ?? count);

  Uint64List copyAsList([int? length]) => Uint64List.fromList(asList(length));
}

extension FloatSodiumPtr on SodiumPointer<Float> {
  Float32List asList([int? length]) => ptr.asTypedList(length ?? count);

  Float32List copyAsList([int? length]) => Float32List.fromList(asList(length));
}

extension DoubleSodiumPtr on SodiumPointer<Double> {
  Float64List asList([int? length]) => ptr.asTypedList(length ?? count);

  Float64List copyAsList([int? length]) => Float64List.fromList(asList(length));
}

extension SodiumString on String {
  SodiumPointer<Int8> toSodiumPointer(
    LibSodiumFFI sodium, {
    int? memoryWidth,
    bool zeroTerminated = false,
    MemoryProtection memoryProtection = MemoryProtection.readWrite,
  }) =>
      toCharArray(
        memoryWidth: memoryWidth,
        zeroTerminated: zeroTerminated,
      ).toSodiumPointer(
        sodium,
        memoryProtection: memoryProtection,
      );
}

extension Int8SodiumList on Int8List {
  SodiumPointer<Int8> toSodiumPointer(
    LibSodiumFFI sodium, {
    MemoryProtection memoryProtection = MemoryProtection.readWrite,
  }) =>
      SodiumPointer.fromList(
        sodium,
        this,
        memoryProtection: memoryProtection,
      );
}

extension Int16SodiumList on Int16List {
  SodiumPointer<Int16> toSodiumPointer(
    LibSodiumFFI sodium, {
    MemoryProtection memoryProtection = MemoryProtection.readWrite,
  }) =>
      SodiumPointer.fromList(
        sodium,
        this,
        memoryProtection: memoryProtection,
      );
}

extension Int32SodiumList on Int32List {
  SodiumPointer<Int32> toSodiumPointer(
    LibSodiumFFI sodium, {
    MemoryProtection memoryProtection = MemoryProtection.readWrite,
  }) =>
      SodiumPointer.fromList(
        sodium,
        this,
        memoryProtection: memoryProtection,
      );
}

extension Int64SodiumList on Int64List {
  SodiumPointer<Int64> toSodiumPointer(
    LibSodiumFFI sodium, {
    MemoryProtection memoryProtection = MemoryProtection.readWrite,
  }) =>
      SodiumPointer.fromList(
        sodium,
        this,
        memoryProtection: memoryProtection,
      );
}

extension Uint8SodiumList on Uint8List {
  SodiumPointer<Uint8> toSodiumPointer(
    LibSodiumFFI sodium, {
    MemoryProtection memoryProtection = MemoryProtection.readWrite,
  }) =>
      SodiumPointer.fromList(
        sodium,
        this,
        memoryProtection: memoryProtection,
      );
}

extension Uint16SodiumList on Uint16List {
  SodiumPointer<Uint16> toSodiumPointer(
    LibSodiumFFI sodium, {
    MemoryProtection memoryProtection = MemoryProtection.readWrite,
  }) =>
      SodiumPointer.fromList(
        sodium,
        this,
        memoryProtection: memoryProtection,
      );
}

extension Uint32SodiumList on Uint32List {
  SodiumPointer<Uint32> toSodiumPointer(
    LibSodiumFFI sodium, {
    MemoryProtection memoryProtection = MemoryProtection.readWrite,
  }) =>
      SodiumPointer.fromList(
        sodium,
        this,
        memoryProtection: memoryProtection,
      );
}

extension Uint64SodiumList on Uint64List {
  SodiumPointer<Uint64> toSodiumPointer(
    LibSodiumFFI sodium, {
    MemoryProtection memoryProtection = MemoryProtection.readWrite,
  }) =>
      SodiumPointer.fromList(
        sodium,
        this,
        memoryProtection: memoryProtection,
      );
}

extension FloatSodiumList on Float32List {
  SodiumPointer<Float> toSodiumPointer(
    LibSodiumFFI sodium, {
    MemoryProtection memoryProtection = MemoryProtection.readWrite,
  }) =>
      SodiumPointer.fromList(
        sodium,
        this,
        memoryProtection: memoryProtection,
      );
}

extension DoubleSodiumList on Float64List {
  SodiumPointer<Double> toSodiumPointer(
    LibSodiumFFI sodium, {
    MemoryProtection memoryProtection = MemoryProtection.readWrite,
  }) =>
      SodiumPointer.fromList(
        sodium,
        this,
        memoryProtection: memoryProtection,
      );
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
