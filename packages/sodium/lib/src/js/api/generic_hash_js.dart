import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/generic_hash.dart';
import '../../api/secure_key.dart';
import '../bindings/js_error.dart';
import '../bindings/secure_key_nullable_x.dart';
import '../bindings/sodium.js.dart';
import '../bindings/to_safe_int.dart';
import 'helpers/generic_hash/generic_hash_consumer_js.dart';
import 'secure_key_js.dart';

@internal
class GenericHashJS with GenericHashValidations implements GenericHash {
  final LibSodiumJS sodium;

  GenericHashJS(this.sodium);

  @override
  int get bytes => sodium.crypto_generichash_BYTES.toSafeUInt32();

  @override
  int get bytesMin => sodium.crypto_generichash_BYTES_MIN.toSafeUInt32();

  @override
  int get bytesMax => sodium.crypto_generichash_BYTES_MAX.toSafeUInt32();

  @override
  int get keyBytes => sodium.crypto_generichash_KEYBYTES.toSafeUInt32();

  @override
  int get keyBytesMin => sodium.crypto_generichash_KEYBYTES_MIN.toSafeUInt32();

  @override
  int get keyBytesMax => sodium.crypto_generichash_KEYBYTES_MAX.toSafeUInt32();

  @override
  SecureKey keygen() => SecureKeyJS(
        sodium,
        JsError.wrap(
          () => sodium.crypto_generichash_keygen(),
        ),
      );

  @override
  Uint8List call({
    required Uint8List message,
    int? outLen,
    SecureKey? key,
  }) {
    if (outLen != null) {
      validateOutLen(outLen);
    }
    if (key != null) {
      validateKey(key);
    }

    return JsError.wrap(
      () => key.runMaybeUnlockedSync(
        (keyData) => sodium.crypto_generichash(
          outLen ?? bytes,
          message,
          keyData,
        ),
      ),
    );
  }

  @override
  GenericHashConsumer createConsumer({
    int? outLen,
    SecureKey? key,
  }) {
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
