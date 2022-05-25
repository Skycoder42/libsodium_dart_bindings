import 'package:meta/meta.dart';

import '../../api/helpers/secret_stream/secret_stream_base.dart';
import '../../api/secret_stream.dart';
import '../../api/secure_key.dart';
import '../bindings/libsodium.ffi.dart';
import 'helpers/keygen_mixin.dart';
import 'helpers/secret_stream/secret_stream_pull_transformer_ffi.dart';
import 'helpers/secret_stream/secret_stream_push_transformer_ffi.dart';

/// @nodoc
@internal
class SecretStreamFFI
    with SecretStreamBase, SecretStreamValidations, KeygenMixin
    implements SecretStream {
  /// @nodoc
  final LibSodiumFFI sodium;

  /// @nodoc
  SecretStreamFFI(this.sodium);

  @override
  int get aBytes => sodium.crypto_secretstream_xchacha20poly1305_abytes();

  @override
  int get headerBytes =>
      sodium.crypto_secretstream_xchacha20poly1305_headerbytes();

  @override
  int get keyBytes => sodium.crypto_secretstream_xchacha20poly1305_keybytes();

  @override
  SecureKey keygen() => keygenImpl(
        sodium: sodium,
        keyBytes: keyBytes,
        implementation: sodium.crypto_secretstream_xchacha20poly1305_keygen,
      );

  @override
  SecretExStreamTransformer<SecretStreamPlainMessage, SecretStreamCipherMessage>
      createPushEx(SecureKey key) {
    validateKey(key);
    return SecretStreamPushTransformerFFI(sodium, key);
  }

  @override
  SecretExStreamTransformer<SecretStreamCipherMessage, SecretStreamPlainMessage>
      createPullEx(
    SecureKey key, {
    bool requireFinalized = true,
  }) {
    validateKey(key);
    return SecretStreamPullTransformerFFI(sodium, key, requireFinalized);
  }
}
