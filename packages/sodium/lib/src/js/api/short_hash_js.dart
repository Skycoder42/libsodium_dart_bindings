// ignore_for_file: unnecessary_lambdas

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/secure_key.dart';
import '../../api/short_hash.dart';
import '../bindings/js_error.dart';
import '../bindings/sodium.js.dart';
import 'secure_key_js.dart';

/// @nodoc
@internal
class ShortHashJS with ShortHashValidations implements ShortHash {
  /// @nodoc
  final LibSodiumJS sodium;

  /// @nodoc
  ShortHashJS(this.sodium);

  @override
  int get bytes => sodium.crypto_shorthash_BYTES;

  @override
  int get keyBytes => sodium.crypto_shorthash_KEYBYTES;

  @override
  SecureKey keygen() =>
      SecureKeyJS(sodium, jsErrorWrap(() => sodium.crypto_shorthash_keygen()));

  @override
  Uint8List call({required Uint8List message, required SecureKey key}) {
    validateKey(key);

    return jsErrorWrap(
      () => key.runUnlockedSync(
        (keyData) => sodium.crypto_shorthash(message.toJS, keyData.toJS).toDart,
      ),
    );
  }
}
