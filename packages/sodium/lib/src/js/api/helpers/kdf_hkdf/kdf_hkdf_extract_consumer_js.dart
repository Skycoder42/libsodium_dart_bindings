import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../../../api/kdf_hkdf.dart';
import '../../../../api/secure_key.dart';
import '../../../bindings/js_error.dart';
import '../../../bindings/sodium.js.dart';
import '../../secure_key_js.dart';

/// @nodoc
@internal
typedef HkdfExtractInitJsFn<T extends JSNumber> =
    T Function(JSUint8Array? salt);

/// @nodoc
@internal
typedef HkdfExtractUpdateJsFn<T extends JSNumber> =
    void Function(T state, JSUint8Array ikm);

/// @nodoc
@internal
typedef HkdfExtractFinalJsFn<T extends JSNumber> =
    JSUint8Array Function(T state);

/// @nodoc
@internal
class KdfHkdfExtractConsumerJS<T extends JSNumber>
    implements KdfHkdfExtractConsumer {
  final LibSodiumJS sodium;

  final HkdfExtractUpdateJsFn<T> extractUpdate;
  final HkdfExtractFinalJsFn<T> extractFinal;

  final _masterKeyCompleter = Completer<SecureKey>();

  late final T _state;

  @override
  Future<SecureKey> get masterKey => _masterKeyCompleter.future;

  KdfHkdfExtractConsumerJS({
    required this.sodium,
    required HkdfExtractInitJsFn<T> extractInit,
    required this.extractUpdate,
    required this.extractFinal,
    Uint8List? salt,
  }) {
    _state = jsErrorWrap(() => extractInit(salt?.toJS));
  }

  @override
  void add(Uint8List data) {
    _ensureNotCompleted();

    jsErrorWrap(() => extractUpdate(_state, data.toJS));
  }

  @override
  Future<void> addStream(Stream<Uint8List> stream) {
    _ensureNotCompleted();
    return stream.map(add).drain<void>();
  }

  @override
  Future<SecureKey> close() {
    _ensureNotCompleted();

    try {
      final result = jsErrorWrap(() => extractFinal(_state));
      _masterKeyCompleter.complete(SecureKeyJS(sodium, result));
    } catch (e, s) {
      _masterKeyCompleter.completeError(e, s);
    }

    return _masterKeyCompleter.future;
  }

  void _ensureNotCompleted() {
    if (_masterKeyCompleter.isCompleted) {
      throw StateError('Master key has already been extracted');
    }
  }
}
