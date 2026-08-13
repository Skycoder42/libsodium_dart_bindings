import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../../../api/xof.dart';
import '../../../bindings/js_error.dart';

@internal
typedef XofInitJsFn<T extends JSNumber> = T Function();

@internal
typedef XofInitWithDomainJsFn<T extends JSNumber> = T Function(int domain);

@internal
typedef XofUpdateJsFn<T extends JSNumber> =
    void Function(T state, JSUint8Array messageChunk);

@internal
typedef XofSqueezeJsFn<T extends JSNumber> =
    JSUint8Array Function(T state, int outLen);

@internal
class XofConsumerJS<T extends JSNumber>
    with XofConsumerValidations
    implements XofConsumer {
  final XofUpdateJsFn<T> xofUpdate;
  final XofSqueezeJsFn<T> xofSqueeze;

  late final T _state;

  var _closed = false;
  var _disposed = false;

  factory XofConsumerJS({
    required XofInitJsFn<T> xofInit,
    required XofUpdateJsFn<T> xofUpdate,
    required XofSqueezeJsFn<T> xofSqueeze,
  }) => XofConsumerJS._(
    xofInit: xofInit,
    xofUpdate: xofUpdate,
    xofSqueeze: xofSqueeze,
  );

  factory XofConsumerJS.domain({
    required XofInitWithDomainJsFn<T> xofInit,
    required XofUpdateJsFn<T> xofUpdate,
    required XofSqueezeJsFn<T> xofSqueeze,
    required int domain,
  }) => XofConsumerJS._(
    xofInitWithDomain: xofInit,
    xofUpdate: xofUpdate,
    xofSqueeze: xofSqueeze,
    domain: domain,
  );

  XofConsumerJS._({
    required this.xofUpdate,
    required this.xofSqueeze,
    XofInitJsFn<T>? xofInit,
    XofInitWithDomainJsFn<T>? xofInitWithDomain,
    int? domain,
  }) {
    _state = jsErrorWrap(
      () => domain != null ? xofInitWithDomain!(domain) : xofInit!(),
    );
  }

  @override
  void add(Uint8List data) {
    _ensureCanAbsorb();

    jsErrorWrap(() => xofUpdate(_state, data.toJS));
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

    return jsErrorWrap(() => xofSqueeze(_state, outLen).toDart);
  }

  @override
  void dispose() {
    // libsodium.js allocates the state internally and does not expose any API
    // to free it again, so there are no resources to release here. Disposing
    // only invalidates the consumer, which keeps the behavior identical to the
    // FFI implementation.
    if (_disposed) {
      return;
    }

    _disposed = true;
    _closed = true;
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
