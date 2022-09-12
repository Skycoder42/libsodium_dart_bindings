import 'dart:async';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../../bindings/js_error.dart';
import '../../../bindings/sodium.js.dart';

/// @nodoc
@internal
mixin SignConsumerJSMixin<T extends Object>
    implements StreamConsumer<Uint8List>, Sink<Uint8List> {
  /// @nodoc
  LibSodiumJS get sodium;

  final _signatureCompleter = Completer<T>();
  late final SignState _state;

  /// @nodoc
  @protected
  Future<T> get result => _signatureCompleter.future;

  /// @nodoc
  @protected
  T finalize(SignState state);

  /// @nodoc
  @protected
  void initState() {
    _state = JsError.wrap(() => sodium.crypto_sign_init());
  }

  @override
  void add(Uint8List data) {
    _ensureNotCompleted();

    JsError.wrap(
      () => sodium.crypto_sign_update(_state, data),
    );
  }

  @override
  Future<void> addStream(Stream<Uint8List> stream) {
    _ensureNotCompleted();
    return stream.map(add).drain<void>();
  }

  @override
  Future<T> close() {
    _ensureNotCompleted();

    try {
      final result = finalize(_state);
      _signatureCompleter.complete(result);
    } catch (e) {
      _signatureCompleter.completeError(e);
    }

    return _signatureCompleter.future;
  }

  void _ensureNotCompleted() {
    if (_signatureCompleter.isCompleted) {
      throw StateError('Signature has already been finalized');
    }
  }
}
