import 'dart:async';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../../../api/generic_hash.dart';
import '../../../../api/secure_key.dart';
import '../../../bindings/js_error.dart';
import '../../../bindings/secure_key_nullable_x.dart';
import '../../../bindings/sodium.js.dart';

/// @nodoc
@internal
class GenericHashConsumerJS implements GenericHashConsumer {
  /// @nodoc
  final LibSodiumJS sodium;

  /// @nodoc
  final int outLen;

  final _hashCompleter = Completer<Uint8List>();
  late final GenerichashState _state;

  @override
  Future<Uint8List> get hash => _hashCompleter.future;

  /// @nodoc
  GenericHashConsumerJS({
    required this.sodium,
    required this.outLen,
    SecureKey? key,
  }) {
    _state = JsError.wrap(
      () => key.runMaybeUnlockedSync(
        (keyData) => sodium.crypto_generichash_init(keyData, outLen),
      ),
    );
  }

  @override
  Future addStream(Stream<Uint8List> stream) {
    _ensureNotCompleted();

    return stream
        .map(
          (event) => JsError.wrap(
            () => sodium.crypto_generichash_update(_state, event),
          ),
        )
        .drain<void>();
  }

  @override
  Future<Uint8List> close() {
    _ensureNotCompleted();

    try {
      final result = JsError.wrap(
        () => sodium.crypto_generichash_final(
          _state,
          outLen,
        ),
      );
      _hashCompleter.complete(result);
    } catch (e, s) {
      _hashCompleter.completeError(e, s);
    }

    return _hashCompleter.future;
  }

  void _ensureNotCompleted() {
    if (_hashCompleter.isCompleted) {
      throw StateError('Hash has already been finalized');
    }
  }
}
