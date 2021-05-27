import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/auth.dart';
import '../../api/secure_key.dart';
import '../bindings/js_error.dart';
import '../bindings/sodium.js.dart';
import '../bindings/to_safe_int.dart';
import 'secure_key_js.dart';

@internal
class AuthJS with AuthValidations implements Auth {
  final LibSodiumJS sodium;

  AuthJS(this.sodium);

  @override
  int get bytes => sodium.crypto_auth_BYTES.toSafeUInt32();

  @override
  int get keyBytes => sodium.crypto_auth_KEYBYTES.toSafeUInt32();

  @override
  SecureKey keygen() => SecureKeyJS(
        sodium,
        JsError.wrap(() => sodium.crypto_auth_keygen()),
      );

  @override
  Uint8List call({
    required Uint8List message,
    required SecureKey key,
  }) {
    validateKey(key);

    return JsError.wrap(
      () => key.runUnlockedSync(
        (keyData) => sodium.crypto_auth(
          message,
          keyData,
        ),
      ),
    );
  }

  @override
  bool verify({
    required Uint8List tag,
    required Uint8List message,
    required SecureKey key,
  }) {
    validateTag(tag);
    validateKey(key);

    return JsError.wrap(
      () => key.runUnlockedSync(
        (keyData) => sodium.crypto_auth_verify(
          tag,
          message,
          keyData,
        ),
      ),
    );
  }
}
