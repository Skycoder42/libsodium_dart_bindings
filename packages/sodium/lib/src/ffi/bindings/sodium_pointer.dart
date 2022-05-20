import 'dart:ffi';
import 'dart:typed_data';

import 'package:meta/meta.dart';
import '../../api/sodium_exception.dart';
import '../../api/string_x.dart';

import 'libsodium.ffi.dart';
import 'memory_protection.dart';
import 'size_t_extension.dart';

/// A C-Pointer wrapper that uses the memory utilities of libsodium.
///
/// See https://libsodium.gitbook.io/doc/memory_management
class SodiumPointer<T extends NativeType> {
  /// libsodium bindings used to access the C API
  final LibSodiumFFI sodium;

  /// The underlying native C pointer
  final Pointer<T> ptr;

  /// The number of elements this pointer is pointing to
  final int count;
  final bool _isView;

  bool _locked;
  MemoryProtection _memoryProtection;

  /// Constructs the pointer from the lib[sodium] API, the raw [ptr] and the
  /// element [count].
  SodiumPointer.raw(this.sodium, this.ptr, this.count)
      : _isView = false,
        _locked = true,
        _memoryProtection = MemoryProtection.readWrite;

  /// Allocates new memory using the libsodium APIs.
  ///
  /// The [sodium] parameter is the reference to the libsodium C API. By
  /// default, the pointer will have a [count] of 1 - meaning it is exactly
  /// `sizeOf<T>` bytes wide. If you set [count] to a higher value, it will be
  /// `sizeOf<T> * count`.
  ///
  /// If you want to immediatly set the [memoryProtection] level, you can do so.
  /// By default, the pointer is not protected and thus is writable.
  ///
  /// By default, the memory is filled with 0xdb bytes. If you want to fill it
  /// with 0x00 instead, simply set [zeroMemory] to true.
  ///
  /// Internally, sodium_malloc or sodium_allocarray are used to allocate the
  /// memory.
  ///
  /// See https://libsodium.gitbook.io/doc/memory_management#guarded-heap-allocations
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
        sodium
            .sodium_allocarray(count.toIntPtr(), elementSize.toIntPtr())
            .cast(),
        count,
      );
    } else {
      ptr = SodiumPointer.raw(
        sodium,
        sodium.sodium_malloc(elementSize.toIntPtr()).cast(),
        1,
      );
    }

    try {
      if (zeroMemory) {
        ptr.zeroMemory();
      }
      return ptr..memoryProtection = memoryProtection;
    } catch (e) {
      ptr.dispose();
      rethrow;
    }
  }

  /// @nodoc
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
      sodium.sodium_allocarray(count.toIntPtr(), typeLen.toIntPtr()).cast<T>(),
      count,
    );
    try {
      sodiumPtr
        ..fill(list)
        ..memoryProtection = memoryProtection;
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

  /// The number of bytes a single element of T is wide.
  ///
  /// This is basically the same as `sizeOf<T>()`.
  int get elementSize => _StaticallyTypedSizeOf.staticSizeOf<T>();

  /// The total number of bytes this pointer is long
  int get byteLength => count * elementSize;

  /// Controlls whether the pointer is locked in memory or not.
  ///
  /// This provides convenient access to sodium_mlock and sodium_munlock via
  /// a single property. All [SodiumPointer]s are locked by default, as
  /// sodium_malloc already lockes them.
  ///
  /// See https://libsodium.gitbook.io/doc/memory_management#locking-memory
  bool get locked => _locked;

  set locked(bool locked) {
    if (locked == _locked) {
      return;
    }

    int result;
    if (locked) {
      result = sodium.sodium_mlock(ptr.cast(), byteLength.toIntPtr());
    } else {
      result = sodium.sodium_munlock(ptr.cast(), byteLength.toIntPtr());
    }
    SodiumException.checkSucceededInt(result);

    _locked = locked;
  }

  /// Controlls the memory protection level of the allocated memory
  ///
  /// This provides convenient access to sodium_mprotect_noaccess,
  /// sodium_mprotect_readonly and sodium_mprotect_readwrite via a single
  /// property. All [SodiumPointer]s are in [MemoryProtection.readWrite] mode
  /// by default, unless set otherwise in the constructor.
  ///
  /// See https://libsodium.gitbook.io/doc/memory_management#guarded-heap-allocations
  MemoryProtection get memoryProtection => _memoryProtection;

  set memoryProtection(MemoryProtection memoryProtection) {
    if (memoryProtection == _memoryProtection) {
      return;
    }

    int result;
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

  /// Provides sodium_memzero
  ///
  /// See https://libsodium.gitbook.io/doc/memory_management#zeroing-memory
  void zeroMemory() => sodium.sodium_memzero(ptr.cast(), byteLength.toIntPtr());

  /// Returns a view of a subset of the memory the pointer is pointing to.
  ///
  /// [offset] specifies the number of elements that should be skipped at the
  /// beginning, [length] controls how many elements are selected.
  ///
  /// **Important:** This method works with *elements*, not *bytes*. This means,
  /// an offset of 1 on a `SodiumPointer<Uint32>` will advanace one element,
  /// which is equivalent to `sizeOf<Uint32>()`, i.e. 4 bytes.
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
      ptr.dynamicElementAt(offset),
      length ?? count - offset,
      _locked,
      _memoryProtection,
    );
  }

  /// Fills an area of the memory with the given data.
  ///
  /// This method copies all elements from [data] and writes the to the memory
  /// this pointer points to, beginning at the element position [offset]. The
  /// [data] must fit into the memory.
  void fill(List<num> data, {int offset = 0}) {
    final end = data.length + offset;
    if (end > count) {
      throw ArgumentError(
        'data and offset are to long. '
        'Can at most write $count elements, '
        'but requested offset=$offset + data=${data.length}',
      );
    }
    final offsetPtr = ptr.dynamicElementAt(offset);
    for (var i = 0; i < data.length; ++i) {
      offsetPtr[i] = data[i];
    }
  }

  /// Disposes the pointer and frees the allocated memory.
  ///
  /// Provides sodium_free
  ///
  /// See https://libsodium.gitbook.io/doc/memory_management#guarded-heap-allocations
  void dispose() {
    if (_isView) {
      return;
    }
    sodium.sodium_free(ptr.cast());
  }
}

extension SodiumPointerX<T extends NativeType> on SodiumPointer<T> {
  T toList<T extends TypedData>(T Function(int) createList, [int? length]) {
    final list = createList(length ?? count);
    // TODO add logic
    return list;
  }
}

/// Extensions on specific sodium pointers for easy conversion to dart types
extension Int8SodiumPtr on SodiumPointer<Int8> {
  /// Returns a dart list view on the pointer.
  ///
  /// The resulting list operates on the same memory. This means if you modify
  /// elements of the list, the data the pointer points to changes as well.
  /// You can either get a reference to the whole pointer, or only the first
  /// [length] elements. (Counted in elements, **not** bytes).
  ///
  /// **Note:** As the returned list is a reference, calling
  /// [SodiumPointer.dispose] is not allowed as long as you still use the
  /// returned list. If you still dispose of the pointer, any try to access the
  /// data will crash your application.
  Int8List asList([int? length]) => ptr.asTypedList(length ?? count);

  /// Returns a dart list copy off the pointer.
  ///
  /// The resulting list is a copy of the memory. This means if you modify
  /// elements of the list, the data the pointer is not changed and you can
  /// safely dispose the pointer without breaking the copied data.
  /// You can either get a copy of the whole pointer, or only the first
  /// [length] elements. (Counted in elements, **not** bytes).
  Int8List copyAsList([int? length]) => Int8List.fromList(asList(length));

  /// Converts the pointer to a dart string using the [utf8] encoding.
  ///
  /// This is simply a shortcut to [Int8ListX.toDartString], which is called on
  /// the result of [asList].
  String toDartString({bool zeroTerminated = false}) =>
      asList().toDartString(zeroTerminated: zeroTerminated);
}

/// Extensions on specific sodium pointers for easy conversion to dart types
extension Int16SodiumPtr on SodiumPointer<Int16> {
  /// Returns a dart list view on the pointer.
  ///
  /// The resulting list operates on the same memory. This means if you modify
  /// elements of the list, the data the pointer points to changes as well.
  /// You can either get a reference to the whole pointer, or only the first
  /// [length] elements. (Counted in elements, **not** bytes).
  ///
  /// **Note:** As the returned list is a reference, calling
  /// [SodiumPointer.dispose] is not allowed as long as you still use the
  /// returned list. If you still dispose of the pointer, any try to access the
  /// data will crash your application.
  Int16List asList([int? length]) => ptr.asTypedList(length ?? count);

  /// Returns a dart list copy off the pointer.
  ///
  /// The resulting list is a copy of the memory. This means if you modify
  /// elements of the list, the data the pointer is not changed and you can
  /// safely dispose the pointer without breaking the copied data.
  /// You can either get a copy of the whole pointer, or only the first
  /// [length] elements. (Counted in elements, **not** bytes).
  Int16List copyAsList([int? length]) => Int16List.fromList(asList(length));
}

/// Extensions on specific sodium pointers for easy conversion to dart types
extension Int32SodiumPtr on SodiumPointer<Int32> {
  /// Returns a dart list view on the pointer.
  ///
  /// The resulting list operates on the same memory. This means if you modify
  /// elements of the list, the data the pointer points to changes as well.
  /// You can either get a reference to the whole pointer, or only the first
  /// [length] elements. (Counted in elements, **not** bytes).
  ///
  /// **Note:** As the returned list is a reference, calling
  /// [SodiumPointer.dispose] is not allowed as long as you still use the
  /// returned list. If you still dispose of the pointer, any try to access the
  /// data will crash your application.
  Int32List asList([int? length]) => ptr.asTypedList(length ?? count);

  /// Returns a dart list copy off the pointer.
  ///
  /// The resulting list is a copy of the memory. This means if you modify
  /// elements of the list, the data the pointer is not changed and you can
  /// safely dispose the pointer without breaking the copied data.
  /// You can either get a copy of the whole pointer, or only the first
  /// [length] elements. (Counted in elements, **not** bytes).
  Int32List copyAsList([int? length]) => Int32List.fromList(asList(length));
}

/// Extensions on specific sodium pointers for easy conversion to dart types
extension Int64SodiumPtr on SodiumPointer<Int64> {
  /// Returns a dart list view on the pointer.
  ///
  /// The resulting list operates on the same memory. This means if you modify
  /// elements of the list, the data the pointer points to changes as well.
  /// You can either get a reference to the whole pointer, or only the first
  /// [length] elements. (Counted in elements, **not** bytes).
  ///
  /// **Note:** As the returned list is a reference, calling
  /// [SodiumPointer.dispose] is not allowed as long as you still use the
  /// returned list. If you still dispose of the pointer, any try to access the
  /// data will crash your application.
  Int64List asList([int? length]) => ptr.asTypedList(length ?? count);

  /// Returns a dart list copy off the pointer.
  ///
  /// The resulting list is a copy of the memory. This means if you modify
  /// elements of the list, the data the pointer is not changed and you can
  /// safely dispose the pointer without breaking the copied data.
  /// You can either get a copy of the whole pointer, or only the first
  /// [length] elements. (Counted in elements, **not** bytes).
  Int64List copyAsList([int? length]) => Int64List.fromList(asList(length));
}

/// Extensions on specific sodium pointers for easy conversion to dart types
extension Uint8SodiumPtr on SodiumPointer<Uint8> {
  /// Returns a dart list view on the pointer.
  ///
  /// The resulting list operates on the same memory. This means if you modify
  /// elements of the list, the data the pointer points to changes as well.
  /// You can either get a reference to the whole pointer, or only the first
  /// [length] elements. (Counted in elements, **not** bytes).
  ///
  /// **Note:** As the returned list is a reference, calling
  /// [SodiumPointer.dispose] is not allowed as long as you still use the
  /// returned list. If you still dispose of the pointer, any try to access the
  /// data will crash your application.
  Uint8List asList([int? length]) => ptr.asTypedList(length ?? count);

  /// Returns a dart list copy off the pointer.
  ///
  /// The resulting list is a copy of the memory. This means if you modify
  /// elements of the list, the data the pointer is not changed and you can
  /// safely dispose the pointer without breaking the copied data.
  /// You can either get a copy of the whole pointer, or only the first
  /// [length] elements. (Counted in elements, **not** bytes).
  Uint8List copyAsList([int? length]) => Uint8List.fromList(asList(length));
}

/// Extensions on specific sodium pointers for easy conversion to dart types
extension Uint16SodiumPtr on SodiumPointer<Uint16> {
  /// Returns a dart list view on the pointer.
  ///
  /// The resulting list operates on the same memory. This means if you modify
  /// elements of the list, the data the pointer points to changes as well.
  /// You can either get a reference to the whole pointer, or only the first
  /// [length] elements. (Counted in elements, **not** bytes).
  ///
  /// **Note:** As the returned list is a reference, calling
  /// [SodiumPointer.dispose] is not allowed as long as you still use the
  /// returned list. If you still dispose of the pointer, any try to access the
  /// data will crash your application.
  Uint16List asList([int? length]) => ptr.asTypedList(length ?? count);

  /// Returns a dart list copy off the pointer.
  ///
  /// The resulting list is a copy of the memory. This means if you modify
  /// elements of the list, the data the pointer is not changed and you can
  /// safely dispose the pointer without breaking the copied data.
  /// You can either get a copy of the whole pointer, or only the first
  /// [length] elements. (Counted in elements, **not** bytes).
  Uint16List copyAsList([int? length]) => Uint16List.fromList(asList(length));
}

/// Extensions on specific sodium pointers for easy conversion to dart types
extension Uint32SodiumPtr on SodiumPointer<Uint32> {
  /// Returns a dart list view on the pointer.
  ///
  /// The resulting list operates on the same memory. This means if you modify
  /// elements of the list, the data the pointer points to changes as well.
  /// You can either get a reference to the whole pointer, or only the first
  /// [length] elements. (Counted in elements, **not** bytes).
  ///
  /// **Note:** As the returned list is a reference, calling
  /// [SodiumPointer.dispose] is not allowed as long as you still use the
  /// returned list. If you still dispose of the pointer, any try to access the
  /// data will crash your application.
  Uint32List asList([int? length]) => ptr.asTypedList(length ?? count);

  /// Returns a dart list copy off the pointer.
  ///
  /// The resulting list is a copy of the memory. This means if you modify
  /// elements of the list, the data the pointer is not changed and you can
  /// safely dispose the pointer without breaking the copied data.
  /// You can either get a copy of the whole pointer, or only the first
  /// [length] elements. (Counted in elements, **not** bytes).
  Uint32List copyAsList([int? length]) => Uint32List.fromList(asList(length));
}

/// Extensions on specific sodium pointers for easy conversion to dart types
extension Uint64SodiumPtr on SodiumPointer<Uint64> {
  /// Returns a dart list view on the pointer.
  ///
  /// The resulting list operates on the same memory. This means if you modify
  /// elements of the list, the data the pointer points to changes as well.
  /// You can either get a reference to the whole pointer, or only the first
  /// [length] elements. (Counted in elements, **not** bytes).
  ///
  /// **Note:** As the returned list is a reference, calling
  /// [SodiumPointer.dispose] is not allowed as long as you still use the
  /// returned list. If you still dispose of the pointer, any try to access the
  /// data will crash your application.
  Uint64List asList([int? length]) => ptr.asTypedList(length ?? count);

  /// Returns a dart list copy off the pointer.
  ///
  /// The resulting list is a copy of the memory. This means if you modify
  /// elements of the list, the data the pointer is not changed and you can
  /// safely dispose the pointer without breaking the copied data.
  /// You can either get a copy of the whole pointer, or only the first
  /// [length] elements. (Counted in elements, **not** bytes).
  Uint64List copyAsList([int? length]) => Uint64List.fromList(asList(length));
}

/// Extensions on specific sodium pointers for easy conversion to dart types
extension FloatSodiumPtr on SodiumPointer<Float> {
  /// Returns a dart list view on the pointer.
  ///
  /// The resulting list operates on the same memory. This means if you modify
  /// elements of the list, the data the pointer points to changes as well.
  /// You can either get a reference to the whole pointer, or only the first
  /// [length] elements. (Counted in elements, **not** bytes).
  ///
  /// **Note:** As the returned list is a reference, calling
  /// [SodiumPointer.dispose] is not allowed as long as you still use the
  /// returned list. If you still dispose of the pointer, any try to access the
  /// data will crash your application.
  Float32List asList([int? length]) => ptr.asTypedList(length ?? count);

  /// Returns a dart list copy off the pointer.
  ///
  /// The resulting list is a copy of the memory. This means if you modify
  /// elements of the list, the data the pointer is not changed and you can
  /// safely dispose the pointer without breaking the copied data.
  /// You can either get a copy of the whole pointer, or only the first
  /// [length] elements. (Counted in elements, **not** bytes).
  Float32List copyAsList([int? length]) => Float32List.fromList(asList(length));
}

/// Extensions on specific sodium pointers for easy conversion to dart types
extension DoubleSodiumPtr on SodiumPointer<Double> {
  /// Returns a dart list view on the pointer.
  ///
  /// The resulting list operates on the same memory. This means if you modify
  /// elements of the list, the data the pointer points to changes as well.
  /// You can either get a reference to the whole pointer, or only the first
  /// [length] elements. (Counted in elements, **not** bytes).
  ///
  /// **Note:** As the returned list is a reference, calling
  /// [SodiumPointer.dispose] is not allowed as long as you still use the
  /// returned list. If you still dispose of the pointer, any try to access the
  /// data will crash your application.
  Float64List asList([int? length]) => ptr.asTypedList(length ?? count);

  /// Returns a dart list copy off the pointer.
  ///
  /// The resulting list is a copy of the memory. This means if you modify
  /// elements of the list, the data the pointer is not changed and you can
  /// safely dispose the pointer without breaking the copied data.
  /// You can either get a copy of the whole pointer, or only the first
  /// [length] elements. (Counted in elements, **not** bytes).
  Float64List copyAsList([int? length]) => Float64List.fromList(asList(length));
}

/// Extensions on String to add sodium pointer operations
extension SodiumString on String {
  /// Converts the string to a [SodiumPointer<Int8>]
  ///
  /// This simpyl combines [StringX.toCharArray] with
  /// [Int8SodiumList.toSodiumPointer].
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

/// Extensions on typed lists to add sodium pointer operations
extension Int8SodiumList on Int8List {
  /// Converts the list to a sodium pointer
  ///
  /// This is done by first allocating a [SodiumPointer] with [length] elements
  /// and the copying all data from the list to the pointer.
  ///
  /// If you want the [memoryProtection] to changed right after the copying is
  /// done, you can do so via this parameter. By default, the pointer keeps the
  /// default [MemoryProtection.readWrite] mode.
  SodiumPointer<T> toSodiumPointer<T extends NativeType>(
    LibSodiumFFI sodium, {
    MemoryProtection memoryProtection = MemoryProtection.readWrite,
  }) {
    assert(
      _StaticallyTypedSizeOf.staticSizeOf<T>() >= sizeOf<Int8>(),
      'Type $T is not able to hold data of type Int8',
    );
    return SodiumPointer.fromList(
      sodium,
      this,
      memoryProtection: memoryProtection,
    );
  }
}

/// Extensions on typed lists to add sodium pointer operations
extension Int16SodiumList on Int16List {
  /// Converts the list to a sodium pointer
  ///
  /// This is done by first allocating a [SodiumPointer] with [length] elements
  /// and the copying all data from the list to the pointer.
  ///
  /// If you want the [memoryProtection] to changed right after the copying is
  /// done, you can do so via this parameter. By default, the pointer keeps the
  /// default [MemoryProtection.readWrite] mode.
  SodiumPointer<T> toSodiumPointer<T extends NativeType>(
    LibSodiumFFI sodium, {
    MemoryProtection memoryProtection = MemoryProtection.readWrite,
  }) {
    assert(
      _StaticallyTypedSizeOf.staticSizeOf<T>() >= sizeOf<Int16>(),
      'Type $T is not able to hold data of type Int16',
    );
    return SodiumPointer.fromList(
      sodium,
      this,
      memoryProtection: memoryProtection,
    );
  }
}

/// Extensions on typed lists to add sodium pointer operations
extension Int32SodiumList on Int32List {
  /// Converts the list to a sodium pointer
  ///
  /// This is done by first allocating a [SodiumPointer] with [length] elements
  /// and the copying all data from the list to the pointer.
  ///
  /// If you want the [memoryProtection] to changed right after the copying is
  /// done, you can do so via this parameter. By default, the pointer keeps the
  /// default [MemoryProtection.readWrite] mode.
  SodiumPointer<T> toSodiumPointer<T extends NativeType>(
    LibSodiumFFI sodium, {
    MemoryProtection memoryProtection = MemoryProtection.readWrite,
  }) {
    assert(
      _StaticallyTypedSizeOf.staticSizeOf<T>() >= sizeOf<Int32>(),
      'Type $T is not able to hold data of type Int32',
    );
    return SodiumPointer.fromList(
      sodium,
      this,
      memoryProtection: memoryProtection,
    );
  }
}

/// Extensions on typed lists to add sodium pointer operations
extension Int64SodiumList on Int64List {
  /// Converts the list to a sodium pointer
  ///
  /// This is done by first allocating a [SodiumPointer] with [length] elements
  /// and the copying all data from the list to the pointer.
  ///
  /// If you want the [memoryProtection] to changed right after the copying is
  /// done, you can do so via this parameter. By default, the pointer keeps the
  /// default [MemoryProtection.readWrite] mode.
  SodiumPointer<T> toSodiumPointer<T extends NativeType>(
    LibSodiumFFI sodium, {
    MemoryProtection memoryProtection = MemoryProtection.readWrite,
  }) {
    assert(
      _StaticallyTypedSizeOf.staticSizeOf<T>() >= sizeOf<Int64>(),
      'Type $T is not able to hold data of type Int64',
    );
    return SodiumPointer.fromList(
      sodium,
      this,
      memoryProtection: memoryProtection,
    );
  }
}

/// Extensions on typed lists to add sodium pointer operations
extension Uint8SodiumList on Uint8List {
  /// Converts the list to a sodium pointer
  ///
  /// This is done by first allocating a [SodiumPointer] with [length] elements
  /// and the copying all data from the list to the pointer.
  ///
  /// If you want the [memoryProtection] to changed right after the copying is
  /// done, you can do so via this parameter. By default, the pointer keeps the
  /// default [MemoryProtection.readWrite] mode.
  SodiumPointer<T> toSodiumPointer<T extends NativeType>(
    LibSodiumFFI sodium, {
    MemoryProtection memoryProtection = MemoryProtection.readWrite,
  }) {
    assert(
      _StaticallyTypedSizeOf.staticSizeOf<T>() >= sizeOf<Uint8>(),
      'Type $T is not able to hold data of type Uint8',
    );
    return SodiumPointer.fromList(
      sodium,
      this,
      memoryProtection: memoryProtection,
    );
  }
}

/// Extensions on typed lists to add sodium pointer operations
extension Uint16SodiumList on Uint16List {
  /// Converts the list to a sodium pointer
  ///
  /// This is done by first allocating a [SodiumPointer] with [length] elements
  /// and the copying all data from the list to the pointer.
  ///
  /// If you want the [memoryProtection] to changed right after the copying is
  /// done, you can do so via this parameter. By default, the pointer keeps the
  /// default [MemoryProtection.readWrite] mode.
  SodiumPointer<T> toSodiumPointer<T extends NativeType>(
    LibSodiumFFI sodium, {
    MemoryProtection memoryProtection = MemoryProtection.readWrite,
  }) {
    assert(
      _StaticallyTypedSizeOf.staticSizeOf<T>() >= sizeOf<Uint16>(),
      'Type $T is not able to hold data of type Uint16',
    );
    return SodiumPointer.fromList(
      sodium,
      this,
      memoryProtection: memoryProtection,
    );
  }
}

/// Extensions on typed lists to add sodium pointer operations
extension Uint32SodiumList on Uint32List {
  /// Converts the list to a sodium pointer
  ///
  /// This is done by first allocating a [SodiumPointer] with [length] elements
  /// and the copying all data from the list to the pointer.
  ///
  /// If you want the [memoryProtection] to changed right after the copying is
  /// done, you can do so via this parameter. By default, the pointer keeps the
  /// default [MemoryProtection.readWrite] mode.
  SodiumPointer<T> toSodiumPointer<T extends NativeType>(
    LibSodiumFFI sodium, {
    MemoryProtection memoryProtection = MemoryProtection.readWrite,
  }) {
    assert(
      _StaticallyTypedSizeOf.staticSizeOf<T>() >= sizeOf<Uint32>(),
      'Type $T is not able to hold data of type Uint32',
    );
    return SodiumPointer.fromList(
      sodium,
      this,
      memoryProtection: memoryProtection,
    );
  }
}

/// Extensions on typed lists to add sodium pointer operations
extension Uint64SodiumList on Uint64List {
  /// Converts the list to a sodium pointer
  ///
  /// This is done by first allocating a [SodiumPointer] with [length] elements
  /// and the copying all data from the list to the pointer.
  ///
  /// If you want the [memoryProtection] to changed right after the copying is
  /// done, you can do so via this parameter. By default, the pointer keeps the
  /// default [MemoryProtection.readWrite] mode.
  SodiumPointer<T> toSodiumPointer<T extends NativeType>(
    LibSodiumFFI sodium, {
    MemoryProtection memoryProtection = MemoryProtection.readWrite,
  }) {
    assert(
      _StaticallyTypedSizeOf.staticSizeOf<T>() >= sizeOf<Uint64>(),
      'Type $T is not able to hold data of type Uint64',
    );
    return SodiumPointer.fromList(
      sodium,
      this,
      memoryProtection: memoryProtection,
    );
  }
}

/// Extensions on typed lists to add sodium pointer operations
extension FloatSodiumList on Float32List {
  /// Converts the list to a sodium pointer
  ///
  /// This is done by first allocating a [SodiumPointer] with [length] elements
  /// and the copying all data from the list to the pointer.
  ///
  /// If you want the [memoryProtection] to changed right after the copying is
  /// done, you can do so via this parameter. By default, the pointer keeps the
  /// default [MemoryProtection.readWrite] mode.
  SodiumPointer<T> toSodiumPointer<T extends NativeType>(
    LibSodiumFFI sodium, {
    MemoryProtection memoryProtection = MemoryProtection.readWrite,
  }) {
    assert(
      _StaticallyTypedSizeOf.staticSizeOf<T>() >= sizeOf<Float>(),
      'Type $T is not able to hold data of type Float',
    );
    return SodiumPointer.fromList(
      sodium,
      this,
      memoryProtection: memoryProtection,
    );
  }
}

/// Extensions on typed lists to add sodium pointer operations
extension DoubleSodiumList on Float64List {
  /// Converts the list to a sodium pointer
  ///
  /// This is done by first allocating a [SodiumPointer] with [length] elements
  /// and the copying all data from the list to the pointer.
  ///
  /// If you want the [memoryProtection] to changed right after the copying is
  /// done, you can do so via this parameter. By default, the pointer keeps the
  /// default [MemoryProtection.readWrite] mode.
  SodiumPointer<T> toSodiumPointer<T extends NativeType>(
    LibSodiumFFI sodium, {
    MemoryProtection memoryProtection = MemoryProtection.readWrite,
  }) {
    assert(
      _StaticallyTypedSizeOf.staticSizeOf<T>() >= sizeOf<Double>(),
      'Type $T is not able to hold data of type Double',
    );
    return SodiumPointer.fromList(
      sodium,
      this,
      memoryProtection: memoryProtection,
    );
  }
}

extension _StaticallyTypedSizeOf<T extends NativeType> on Pointer<T> {
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
      case Char:
        return sizeOf<Char>();
      case Short:
        return sizeOf<Short>();
      case Int:
        return sizeOf<Int>();
      case Long:
        return sizeOf<Long>();
      case LongLong:
        return sizeOf<LongLong>();
      case UnsignedChar:
        return sizeOf<UnsignedChar>();
      case UnsignedShort:
        return sizeOf<UnsignedShort>();
      case UnsignedInt:
        return sizeOf<UnsignedInt>();
      case UnsignedLong:
        return sizeOf<UnsignedLong>();
      case UnsignedLongLong:
        return sizeOf<UnsignedLongLong>();
      case SignedChar:
        return sizeOf<SignedChar>();
      case IntPtr:
        return sizeOf<IntPtr>();
      case UintPtr:
        return sizeOf<UintPtr>();
      case Size:
        return sizeOf<Size>();
      case WChar:
        return sizeOf<WChar>();
      default:
        throw UnsupportedError(
          'Cannot create a SodiumPointer for $T. T must be a primitive type',
        );
    }
  }

  Pointer<T> dynamicElementAt(int index) {
    switch (T) {
      case Int8:
        return (this as Pointer<Int8>).elementAt(index) as Pointer<T>;
      case Int16:
        return (this as Pointer<Int16>).elementAt(index) as Pointer<T>;
      case Int32:
        return (this as Pointer<Int32>).elementAt(index) as Pointer<T>;
      case Int64:
        return (this as Pointer<Int64>).elementAt(index) as Pointer<T>;
      case Uint8:
        return (this as Pointer<Uint8>).elementAt(index) as Pointer<T>;
      case Uint16:
        return (this as Pointer<Uint16>).elementAt(index) as Pointer<T>;
      case Uint32:
        return (this as Pointer<Uint32>).elementAt(index) as Pointer<T>;
      case Uint64:
        return (this as Pointer<Uint64>).elementAt(index) as Pointer<T>;
      case Float:
        return (this as Pointer<Float>).elementAt(index) as Pointer<T>;
      case Double:
        return (this as Pointer<Double>).elementAt(index) as Pointer<T>;
      case Char:
        return (this as Pointer<Char>).elementAt(index) as Pointer<T>;
      case Short:
        return (this as Pointer<Short>).elementAt(index) as Pointer<T>;
      case Int:
        return (this as Pointer<Int>).elementAt(index) as Pointer<T>;
      case Long:
        return (this as Pointer<Long>).elementAt(index) as Pointer<T>;
      case LongLong:
        return (this as Pointer<LongLong>).elementAt(index) as Pointer<T>;
      case UnsignedChar:
        return (this as Pointer<UnsignedChar>).elementAt(index) as Pointer<T>;
      case UnsignedShort:
        return (this as Pointer<UnsignedShort>).elementAt(index) as Pointer<T>;
      case UnsignedInt:
        return (this as Pointer<UnsignedInt>).elementAt(index) as Pointer<T>;
      case UnsignedLong:
        return (this as Pointer<UnsignedLong>).elementAt(index) as Pointer<T>;
      case UnsignedLongLong:
        return (this as Pointer<UnsignedLongLong>).elementAt(index)
            as Pointer<T>;
      case SignedChar:
        return (this as Pointer<SignedChar>).elementAt(index) as Pointer<T>;
      case IntPtr:
        return (this as Pointer<IntPtr>).elementAt(index) as Pointer<T>;
      case UintPtr:
        return (this as Pointer<UintPtr>).elementAt(index) as Pointer<T>;
      case Size:
        return (this as Pointer<Size>).elementAt(index) as Pointer<T>;
      case WChar:
        return (this as Pointer<WChar>).elementAt(index) as Pointer<T>;
      default:
        throw UnsupportedError(
          'Cannot create a SodiumPointer for $T. T must be a primitive type',
        );
    }
  }

  // ignore: unused_element
  num operator [](int index) {
    switch (T) {
      case Int8:
        return Uint8Pointer(this as Pointer<Uint8>)[index];
      case Int16:
        return Int16Pointer(this as Pointer<Int16>)[index];
      case Int32:
        return Int32Pointer(this as Pointer<Int32>)[index];
      case Int64:
        return Int64Pointer(this as Pointer<Int64>)[index];
      case Uint8:
        return Uint8Pointer(this as Pointer<Uint8>)[index];
      case Uint16:
        return Uint16Pointer(this as Pointer<Uint16>)[index];
      case Uint32:
        return Uint32Pointer(this as Pointer<Uint32>)[index];
      case Uint64:
        return Uint64Pointer(this as Pointer<Uint64>)[index];
      case Float:
        return FloatPointer(this as Pointer<Float>)[index];
      case Double:
        return DoublePointer(this as Pointer<Double>)[index];
      case Char:
        return AbiSpecificIntegerPointer(this as Pointer<Char>)[index];
      case Short:
        return AbiSpecificIntegerPointer(this as Pointer<Short>)[index];
      case Int:
        return AbiSpecificIntegerPointer(this as Pointer<Int>)[index];
      case Long:
        return AbiSpecificIntegerPointer(this as Pointer<Long>)[index];
      case LongLong:
        return AbiSpecificIntegerPointer(this as Pointer<LongLong>)[index];
      case UnsignedChar:
        return AbiSpecificIntegerPointer(this as Pointer<UnsignedChar>)[index];
      case UnsignedShort:
        return AbiSpecificIntegerPointer(this as Pointer<UnsignedShort>)[index];
      case UnsignedInt:
        return AbiSpecificIntegerPointer(this as Pointer<UnsignedInt>)[index];
      case UnsignedLong:
        return AbiSpecificIntegerPointer(this as Pointer<UnsignedLong>)[index];
      case UnsignedLongLong:
        return AbiSpecificIntegerPointer(
          this as Pointer<UnsignedLongLong>,
        )[index];
      case SignedChar:
        return AbiSpecificIntegerPointer(this as Pointer<SignedChar>)[index];
      case IntPtr:
        return AbiSpecificIntegerPointer(this as Pointer<IntPtr>)[index];
      case UintPtr:
        return AbiSpecificIntegerPointer(this as Pointer<UintPtr>)[index];
      case Size:
        return AbiSpecificIntegerPointer(this as Pointer<Size>)[index];
      case WChar:
        return AbiSpecificIntegerPointer(this as Pointer<WChar>)[index];
      default:
        throw UnsupportedError(
          'Cannot create a SodiumPointer for $T. T must be a primitive type',
        );
    }
  }

  void operator []=(int index, num value) {
    switch (T) {
      case Int8:
        Uint8Pointer(this as Pointer<Uint8>)[index] = value as int;
        break;
      case Int16:
        Int16Pointer(this as Pointer<Int16>)[index] = value as int;
        break;
      case Int32:
        Int32Pointer(this as Pointer<Int32>)[index] = value as int;
        break;
      case Int64:
        Int64Pointer(this as Pointer<Int64>)[index] = value as int;
        break;
      case Uint8:
        Uint8Pointer(this as Pointer<Uint8>)[index] = value as int;
        break;
      case Uint16:
        Uint16Pointer(this as Pointer<Uint16>)[index] = value as int;
        break;
      case Uint32:
        Uint32Pointer(this as Pointer<Uint32>)[index] = value as int;
        break;
      case Uint64:
        Uint64Pointer(this as Pointer<Uint64>)[index] = value as int;
        break;
      case Float:
        FloatPointer(this as Pointer<Float>)[index] = value as double;
        break;
      case Double:
        DoublePointer(this as Pointer<Double>)[index] = value as double;
        break;
      case Char:
        AbiSpecificIntegerPointer(this as Pointer<Char>)[index] = value as int;
        break;
      case Short:
        AbiSpecificIntegerPointer(this as Pointer<Short>)[index] = value as int;
        break;
      case Int:
        AbiSpecificIntegerPointer(this as Pointer<Int>)[index] = value as int;
        break;
      case Long:
        AbiSpecificIntegerPointer(this as Pointer<Long>)[index] = value as int;
        break;
      case LongLong:
        AbiSpecificIntegerPointer(this as Pointer<LongLong>)[index] =
            value as int;
        break;
      case UnsignedChar:
        AbiSpecificIntegerPointer(this as Pointer<UnsignedChar>)[index] =
            value as int;
        break;
      case UnsignedShort:
        AbiSpecificIntegerPointer(this as Pointer<UnsignedShort>)[index] =
            value as int;
        break;
      case UnsignedInt:
        AbiSpecificIntegerPointer(this as Pointer<UnsignedInt>)[index] =
            value as int;
        break;
      case UnsignedLong:
        AbiSpecificIntegerPointer(this as Pointer<UnsignedLong>)[index] =
            value as int;
        break;
      case UnsignedLongLong:
        AbiSpecificIntegerPointer(this as Pointer<UnsignedLongLong>)[index] =
            value as int;
        break;
      case SignedChar:
        AbiSpecificIntegerPointer(this as Pointer<SignedChar>)[index] =
            value as int;
        break;
      case IntPtr:
        AbiSpecificIntegerPointer(this as Pointer<IntPtr>)[index] =
            value as int;
        break;
      case UintPtr:
        AbiSpecificIntegerPointer(this as Pointer<UintPtr>)[index] =
            value as int;
        break;
      case Size:
        AbiSpecificIntegerPointer(this as Pointer<Size>)[index] = value as int;
        break;
      case WChar:
        AbiSpecificIntegerPointer(this as Pointer<WChar>)[index] = value as int;
        break;
      default:
        throw UnsupportedError(
          'Cannot create a SodiumPointer for $T. T must be a primitive type',
        );
    }
  }
}
