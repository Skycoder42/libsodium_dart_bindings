import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../../../api/helpers/secret_stream/pull/secret_stream_pull_transformer.dart';
import '../../../../api/secret_stream.dart';
import '../../../../api/secure_key.dart';
import '../../../../api/sodium_exception.dart';
import '../../../bindings/js_error.dart';
import '../../../bindings/sodium.js.dart';
import '../../../bindings/to_safe_int.dart';
import 'secret_stream_message_tag_x.dart';

class SecretStreamPullTransformerSinkJS
    extends SecretStreamPullTransformerSink<num> {
  final LibSodiumJS sodium;

  SecretStreamPullTransformerSinkJS(
    this.sodium,
    // ignore: avoid_positional_boolean_parameters
    bool requireFinalized,
  ) : super(requireFinalized);

  @override
  int get headerBytes =>
      sodium.crypto_secretstream_xchacha20poly1305_HEADERBYTES.toSafeUInt32();

  @override
  num initialize(
    SecureKey key,
    Uint8List header,
  ) =>
      JsError.wrap(
        () => key.runUnlockedSync(
          (keyData) => sodium.crypto_secretstream_xchacha20poly1305_init_pull(
            header,
            keyData,
          ),
        ),
      );

  @override
  void rekey(num cryptoState) => JsError.wrap(
        () => sodium.crypto_secretstream_xchacha20poly1305_rekey(cryptoState),
      );

  @override
  SecretStreamPlainMessage decryptMessage(
    num cryptoState,
    SecretStreamCipherMessage event,
  ) {
    final dynamic pullResult = JsError.wrap<dynamic>(
      () => sodium.crypto_secretstream_xchacha20poly1305_pull(
        cryptoState,
        event.message,
        event.additionalData,
      ),
    );

    if (pullResult is bool) {
      assert(!pullResult, 'unexpected boolean value for SecretStreamPull');
      throw SodiumException();
    } else if (pullResult is SecretStreamPull) {
      return SecretStreamPlainMessage(
        pullResult.message,
        additionalData: event.additionalData,
        tag: SecretStreamMessageTagX.fromValue(
          sodium,
          pullResult.tag.toSafeUInt32(),
        ),
      );
    } else {
      throw TypeError();
    }
  }

  @override
  void disposeState(num cryptoState) {}
}

@internal
class SecretStreamPullTransformerJS extends SecretStreamPullTransformer<num> {
  final LibSodiumJS sodium;

  const SecretStreamPullTransformerJS(
    this.sodium,
    SecureKey key,
    // ignore: avoid_positional_boolean_parameters
    bool requireFinalized,
  ) : super(key, requireFinalized);

  @override
  SecretStreamPullTransformerSink<num> createSink(bool requireFinalized) =>
      SecretStreamPullTransformerSinkJS(sodium, requireFinalized);
}
