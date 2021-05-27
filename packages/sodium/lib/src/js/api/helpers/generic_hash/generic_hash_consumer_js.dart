import 'dart:async';
import 'dart:typed_data';

import '../../../../api/generic_hash.dart';
import '../../../../api/secure_key.dart';
import '../../../bindings/js_error.dart';
import '../../../bindings/secure_key_nullable_x.dart';
import '../../../bindings/sodium.js.dart';

class GenericHashConsumerJS implements GenericHashConsumer {
  final LibSodiumJS sodium;
  final int outLen;

  final _hashCompleter = Completer<Uint8List>();
  late final GenerichashState _state;

  @override
  Future<Uint8List> get hash => _hashCompleter.future;

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
