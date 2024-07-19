// ignore_for_file: unnecessary_lambdas

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/auth.dart';
import '../../api/secure_key.dart';
import '../bindings/js_error.dart';
import '../bindings/sodium.js.dart';
import 'secure_key_js.dart';

/// @nodoc
@internal
class AuthJS with AuthValidations implements Auth {
  /// @nodoc
  final LibSodiumJS sodium;

  /// @nodoc
  AuthJS(this.sodium);

  @override
  int get bytes => sodium.crypto_auth_BYTES;

  @override
  int get keyBytes => sodium.crypto_auth_KEYBYTES;

  @override
  SecureKey keygen() => SecureKeyJS(
        sodium,
        jsErrorWrap(() => sodium.crypto_auth_keygen()),
      );

  @override
  Uint8List call({
    required Uint8List message,
    required SecureKey key,
  }) {
    validateKey(key);

    return jsErrorWrap(
      () => key.runUnlockedSync(
        (keyData) => sodium
            .crypto_auth(
              message.toJS,
              keyData.toJS,
            )
            .toDart,
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

    return jsErrorWrap(
      () => key.runUnlockedSync(
        (keyData) => sodium.crypto_auth_verify(
          tag.toJS,
          message.toJS,
          keyData.toJS,
        ),
      ),
    );
  }
}
