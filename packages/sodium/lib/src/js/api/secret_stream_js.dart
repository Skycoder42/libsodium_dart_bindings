// ignore_for_file: unnecessary_lambdas

import 'package:meta/meta.dart';

import '../../api/helpers/secret_stream/secret_stream_base.dart';
import '../../api/secret_stream.dart';
import '../../api/secure_key.dart';
import '../bindings/js_error.dart';
import '../bindings/sodium.js.dart';
import '../bindings/to_safe_int.dart';
import 'helpers/secret_stream/secret_stream_pull_transformer_js.dart';
import 'helpers/secret_stream/secret_stream_push_transformer_js.dart';
import 'secure_key_js.dart';

/// @nodoc
@internal
class SecretStreamJS
    with SecretStreamBase, SecretStreamValidations
    implements SecretStream {
  /// @nodoc
  final LibSodiumJS sodium;

  /// @nodoc
  SecretStreamJS(this.sodium);

  @override
  int get aBytes =>
      sodium.crypto_secretstream_xchacha20poly1305_ABYTES.toSafeUInt32();

  @override
  int get headerBytes =>
      sodium.crypto_secretstream_xchacha20poly1305_HEADERBYTES.toSafeUInt32();

  @override
  int get keyBytes =>
      sodium.crypto_secretstream_xchacha20poly1305_KEYBYTES.toSafeUInt32();

  @override
  SecureKey keygen() => SecureKeyJS(
        sodium,
        jsErrorWrap(
          () => sodium.crypto_secretstream_xchacha20poly1305_keygen(),
        ),
      );

  @override
  SecretExStreamTransformer<SecretStreamPlainMessage, SecretStreamCipherMessage>
      createPushEx(
    SecureKey key,
  ) {
    validateKey(key);
    return SecretStreamPushTransformerJS(sodium, key);
  }

  @override
  SecretExStreamTransformer<SecretStreamCipherMessage, SecretStreamPlainMessage>
      createPullEx(
    SecureKey key, {
    bool requireFinalized = true,
  }) {
    validateKey(key);
    return SecretStreamPullTransformerJS(sodium, key, requireFinalized);
  }
}
