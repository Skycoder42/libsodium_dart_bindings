import 'dart:async';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../../../api/sodium_exception.dart';
import '../../../../api/xof.dart';
import '../../../bindings/libsodium.ffi.wrapper.dart';
import '../../../bindings/sodium_pointer.dart';
import '../../../bindings/sodium_scope.dart';

@internal
typedef XofInitFn<T extends NativeType> = int Function(Pointer<T> state);

@internal
typedef XofInitWithDomainFn<T extends NativeType> = int Function(
  Pointer<T> state,
  int domain,
);

@internal
typedef XofUpdateFn<T extends NativeType> = int Function(
  Pointer<T> state,
  Pointer<UnsignedChar> in$,
  int inLen,
);

@internal
typedef XofSqueezeFn<T extends NativeType> = int Function(
  Pointer<T> state,
  Pointer<UnsignedChar> out,
  int outLen,
);

@internal
class XofConsumerFFI<T extends NativeType>
    with XofConsumerValidations
    implements XofConsumer {
  final LibSodiumFFI sodium;
  final XofUpdateFn<T> xofUpdate;
  final XofSqueezeFn<T> xofSqueeze;

  late final SodiumPointer<UnsignedChar> _state;

  var _closed = false;
  var _disposed = false;

  factory({
    required LibSodiumFFI sodium,
    required int stateBytes,
    required XofInitFn<T> xofInit,
    required XofUpdateFn<T> xofUpdate,
    required XofSqueezeFn<T> xofSqueeze,
  }) => XofConsumerFFI._(
    sodium: sodium,
    stateBytes: stateBytes,
    xofInit: xofInit,
    xofUpdate: xofUpdate,
    xofSqueeze: xofSqueeze,
  );

  factory domain({
    required LibSodiumFFI sodium,
    required int stateBytes,
    required XofInitWithDomainFn<T> xofInit,
    required XofUpdateFn<T> xofUpdate,
    required XofSqueezeFn<T> xofSqueeze,
    required int domain,
  }) => XofConsumerFFI._(
    sodium: sodium,
    stateBytes: stateBytes,
    xofInitWithDomain: xofInit,
    xofUpdate: xofUpdate,
    xofSqueeze: xofSqueeze,
    domain: domain,
  );

  new _({
    required this.sodium,
    required int stateBytes,
    required this.xofUpdate,
    required this.xofSqueeze,
    XofInitFn<T>? xofInit,
    XofInitWithDomainFn<T>? xofInitWithDomain,
    int? domain,
  }) {
    _state = SodiumPointer.alloc(sodium, count: stateBytes, zeroMemory: true);

    try {
      final result = domain != null
          ? xofInitWithDomain!(_state.ptr.cast(), domain)
          : xofInit!(_state.ptr.cast());
      SodiumException.checkSucceededInt(result);

      _state.memoryProtection = .noAccess;
    } catch (e) {
      _state.dispose();
      rethrow;
    }
  }

  @override
  void add(Uint8List data) {
    _ensureCanAbsorb();

    sodiumScope(sodium, (scope) {
      final messagePtr = scope.copyList<UnsignedChar>(data);

      _state.memoryProtection = .readWrite;
      try {
        final result = xofUpdate(
          _state.ptr.cast(),
          messagePtr.ptr,
          messagePtr.count,
        );
        SodiumException.checkSucceededInt(result);
      } finally {
        _state.memoryProtection = .noAccess;
      }
    });
  }

  @override
  Future<void> addStream(Stream<Uint8List> stream) {
    _ensureCanAbsorb();
    return stream.map(add).drain<void>();
  }

  @override
  Future<void> close() {
    _ensureNotDisposed();
    _closed = true;
    return .value();
  }

  @override
  Uint8List squeeze(int outLen) {
    _ensureNotDisposed();
    validateOutLen(outLen);

    // Squeezing ends the absorbing phase - libsodium does not allow any more
    // data to be absorbed after the first squeeze.
    _closed = true;

    return sodiumScope(sodium, (scope) {
      final outPtr = scope.alloc<UnsignedChar>(outLen);

      _state.memoryProtection = .readWrite;
      try {
        final result = xofSqueeze(_state.ptr.cast(), outPtr.ptr, outPtr.count);
        SodiumException.checkSucceededInt(result);
      } finally {
        _state.memoryProtection = .noAccess;
      }

      return scope.takeBytes<Uint8List>(outPtr);
    });
  }

  @override
  void dispose() {
    if (_disposed) {
      return;
    }

    _disposed = true;
    _closed = true;
    _state.dispose();
  }

  void _ensureNotDisposed() {
    if (_disposed) {
      throw StateError('The XOF consumer has already been disposed');
    }
  }

  void _ensureCanAbsorb() {
    _ensureNotDisposed();

    if (_closed) {
      throw StateError(
        'The XOF consumer has already been closed - no more data can be '
        'absorbed',
      );
    }
  }
}
