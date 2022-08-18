import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/secure_key.dart';
import '../../api/short_hash.dart';
import '../bindings/js_error.dart';
import '../bindings/sodium.js.dart';
import '../bindings/to_safe_int.dart';
import 'secure_key_js.dart';

/// @nodoc
@internal
class ShortHashJS with ShortHashValidations implements ShortHash {
  /// @nodoc
  final LibSodiumJS sodium;

  /// @nodoc
  ShortHashJS(this.sodium);

  @override
  int get bytes => sodium.crypto_shorthash_BYTES.toSafeUInt32();

  @override
  int get keyBytes => sodium.crypto_shorthash_KEYBYTES.toSafeUInt32();

  @override
  SecureKey keygen() => SecureKeyJS(
        sodium,
        JsError.wrap(sodium.crypto_shorthash_keygen),
      );

  @override
  Uint8List call({
    required Uint8List message,
    required SecureKey key,
  }) {
    validateKey(key);

    return JsError.wrap(
      () => key.runUnlockedSync(
        (keyData) => sodium.crypto_shorthash(message, keyData),
      ),
    );
  }
}
