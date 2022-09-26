import 'dart:ffi';
import 'dart:typed_data';

import 'package:meta/meta.dart';
import '../../api/sodium_exception.dart';
import '../../api/string_x.dart';

import 'libsodium.ffi.dart';
import 'memory_protection.dart';

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
  /// If you want to immediately set the [memoryProtection] level, you can do so
  /// by changing the parameter to a different value. By default, the pointer is
  /// not protected and thus is writable.
  ///
  /// By default, the memory is filled with `0xdb` bytes. If you want to fill it
  /// with `0x00` instead, simply set [zeroMemory] to true.
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
      sodium.sodium_allocarray(count, typeLen).cast<T>(),
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

  /// Controls whether the pointer is locked in memory or not.
  ///
  /// This provides convenient access to sodium_mlock and sodium_munlock via
  /// a single property. All [SodiumPointer]s are locked by default, as
  /// sodium_malloc already locks them.
  ///
  /// See https://libsodium.gitbook.io/doc/memory_management#locking-memory
  bool get locked => _locked;

  set locked(bool locked) {
    if (locked == _locked) {
      return;
    }

    int result;
    if (locked) {
      result = sodium.sodium_mlock(ptr.cast(), byteLength);
    } else {
      result = sodium.sodium_munlock(ptr.cast(), byteLength);
    }
    SodiumException.checkSucceededInt(result);

    _locked = locked;
  }

  /// Controls the memory protection level of the allocated memory
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
  void zeroMemory() => sodium.sodium_memzero(ptr.cast(), byteLength);

  /// Returns a view of a subset of the memory the pointer is pointing to.
  ///
  /// [offset] specifies the number of elements that should be skipped at the
  /// beginning, [length] controls how many elements are selected.
  ///
  /// **Important:** This method works with *elements*, not *bytes*. This means,
  /// an offset of 1 on a `SodiumPointer<Uint32>` will advance one element,
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
  void fill<TNum extends num>(List<TNum> data, {int offset = 0}) {
    final end = data.length + offset;
    if (end > count) {
      throw ArgumentError(
        'data and offset are to long. '
        'Can at most write $count elements, '
        'but requested offset=$offset + data=${data.length}',
      );
    }
    asListView().setAll(offset, data);
  }

  /// Returns a dart list view on the pointer.
  ///
  /// The resulting list operates on the same memory. This means if you modify
  /// elements of the list, the data the pointer points to changes as well.
  /// You can either get a reference to the whole pointer, or use [viewAt] to
  /// select a specific portion of the pointer. All returned lists are
  /// guaranteed to also implement the [TypedData] interface.
  ///
  /// **Note:** As the returned list is a reference, calling
  /// [SodiumPointer.dispose] is not allowed as long as you still use the
  /// returned list. If you still dispose of the pointer, any try to access the
  /// data will crash your application.
  List<TNum> asListView<TNum extends num>() {
    final signage = _StaticallyTypedSizeOf.signage<T>();
    switch (signage) {
      case _Signage.signed:
        if (elementSize <= sizeOf<Int8>()) {
          return ptr.cast<Int8>().asTypedList(count) as List<TNum>;
        } else if (elementSize <= sizeOf<Int16>()) {
          return ptr.cast<Int16>().asTypedList(count) as List<TNum>;
        } else if (elementSize <= sizeOf<Int32>()) {
          return ptr.cast<Int32>().asTypedList(count) as List<TNum>;
        } else if (elementSize <= sizeOf<Int64>()) {
          return ptr.cast<Int64>().asTypedList(count) as List<TNum>;
        }
        break;
      case _Signage.unsigned:
        if (elementSize <= sizeOf<Uint8>()) {
          return ptr.cast<Uint8>().asTypedList(count) as List<TNum>;
        } else if (elementSize <= sizeOf<Uint16>()) {
          return ptr.cast<Uint16>().asTypedList(count) as List<TNum>;
        } else if (elementSize <= sizeOf<Uint32>()) {
          return ptr.cast<Uint32>().asTypedList(count) as List<TNum>;
        } else if (elementSize <= sizeOf<Uint64>()) {
          return ptr.cast<Uint64>().asTypedList(count) as List<TNum>;
        }
        break;
      case _Signage.float:
        if (elementSize <= sizeOf<Float>()) {
          return ptr.cast<Float>().asTypedList(count) as List<TNum>;
        } else if (elementSize <= sizeOf<Double>()) {
          return ptr.cast<Double>().asTypedList(count) as List<TNum>;
        }
        break;
    }

    // coverage:ignore-start
    throw UnsupportedError(
      'Cannot create a list view for a pointer of type $T',
    );
    // coverage:ignore-end
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

/// Extensions on specific sodium pointers for easy conversion to dart types
extension CharSodiumPtr on SodiumPointer<Char> {
  /// Converts the pointer to a dart string using the [utf8] encoding.
  ///
  /// This is simply a shortcut to [Int8ListX.toDartString], which is called on
  /// the data of the [ptr].
  String toDartString({bool zeroTerminated = false}) => ptr
      .cast<Int8>()
      .asTypedList(count)
      .toDartString(zeroTerminated: zeroTerminated);
}

/// Extensions on String to add sodium pointer operations
extension SodiumString on String {
  /// Converts the string to a [SodiumPointer<Int8>]
  ///
  /// This simply combines [StringX.toCharArray] with
  /// [Int8SodiumList.toSodiumPointer].
  SodiumPointer<Char> toSodiumPointer(
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
extension TypedNumberListX on List<num> {
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
    if (this is! TypedData) {
      throw UnsupportedError(
        'The toSodiumPointer extension can only be used on typed data lists '
        'like Uint8List',
      );
    }
    final typedDataThis = this as TypedData;

    if (_StaticallyTypedSizeOf.staticSizeOf<T>() <
        typedDataThis.elementSizeInBytes) {
      throw ArgumentError.value(
        T,
        'T',
        'A $runtimeType does not fit into SodiumPointer of type',
      );
    }

    return SodiumPointer.fromList(
      sodium,
      this,
      memoryProtection: memoryProtection,
    );
  }
}

enum _Signage {
  signed,
  unsigned,
  float,
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
      // coverage:ignore-start
      default:
        throw UnsupportedError(
          'Cannot create a SodiumPointer for $T. T must be a primitive type',
        );
      // coverage:ignore-end
    }
  }

  static _Signage signage<T>() {
    switch (T) {
      case Int8:
      case Int16:
      case Int32:
      case Int64:
      case Char:
      case Short:
      case Int:
      case Long:
      case LongLong:
      case SignedChar:
      case IntPtr:
      case WChar:
        return _Signage.signed;
      case Uint8:
      case Uint16:
      case Uint32:
      case Uint64:
      case UnsignedChar:
      case UnsignedShort:
      case UnsignedInt:
      case UnsignedLong:
      case UnsignedLongLong:
      case UintPtr:
      case Size:
        return _Signage.unsigned;
      case Float:
      case Double:
        return _Signage.float;
      // coverage:ignore-start
      default:
        throw UnsupportedError(
          'Cannot create a SodiumPointer for $T. T must be a primitive type',
        );
      // coverage:ignore-end
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
      // coverage:ignore-start
      default:
        throw UnsupportedError(
          'Cannot create a SodiumPointer for $T. T must be a primitive type',
        );
      // coverage:ignore-end
    }
  }
}
