// ignore_for_file: unnecessary_lambdas

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/generic_hash.dart';
import '../../api/secure_key.dart';
import '../bindings/js_error.dart';
import '../bindings/secure_key_nullable_x.dart';
import '../bindings/sodium.js.dart';
import 'helpers/generic_hash/generic_hash_consumer_js.dart';
import 'secure_key_js.dart';

/// @nodoc
@internal
class GenericHashJS with GenericHashValidations implements GenericHash {
  /// @nodoc
  final LibSodiumJS sodium;

  /// @nodoc
  GenericHashJS(this.sodium);

  @override
  int get bytes => sodium.crypto_generichash_BYTES;

  @override
  int get bytesMin => sodium.crypto_generichash_BYTES_MIN;

  @override
  int get bytesMax => sodium.crypto_generichash_BYTES_MAX;

  @override
  int get keyBytes => sodium.crypto_generichash_KEYBYTES;

  @override
  int get keyBytesMin => sodium.crypto_generichash_KEYBYTES_MIN;

  @override
  int get keyBytesMax => sodium.crypto_generichash_KEYBYTES_MAX;

  @override
  SecureKey keygen() => SecureKeyJS(
    sodium,
    jsErrorWrap(() => sodium.crypto_generichash_keygen()),
  );

  @override
  Uint8List call({required Uint8List message, int? outLen, SecureKey? key}) {
    if (outLen != null) {
      validateOutLen(outLen);
    }
    if (key != null) {
      validateKey(key);
    }

    return jsErrorWrap(
      () => key.runMaybeUnlockedSync(
        (keyData) => sodium
            .crypto_generichash(outLen ?? bytes, message.toJS, keyData?.toJS)
            .toDart,
      ),
    );
  }

  @override
  GenericHashConsumer createConsumer({int? outLen, SecureKey? key}) {
    if (outLen != null) {
      validateOutLen(outLen);
    }
    if (key != null) {
      validateKey(key);
    }

    return GenericHashConsumerJS(
      sodium: sodium,
      outLen: outLen ?? bytes,
      key: key,
    );
  }
}
