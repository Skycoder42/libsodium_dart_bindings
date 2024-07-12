import 'package:meta/meta.dart';

import '../../api/kdf.dart';
import '../../api/secure_key.dart';
import '../bindings/js_error.dart';
import '../bindings/sodium.js.dart';
import '../bindings/to_safe_int.dart';
import 'secure_key_js.dart';

/// @nodoc
@internal
class KdfJS with KdfValidations implements Kdf {
  /// @nodoc
  final LibSodiumJS sodium;

  /// @nodoc
  KdfJS(this.sodium);

  @override
  int get bytesMin => sodium.crypto_kdf_BYTES_MIN.toSafeUInt32();

  @override
  int get bytesMax => sodium.crypto_kdf_BYTES_MAX.toSafeUInt32();

  @override
  int get contextBytes => sodium.crypto_kdf_CONTEXTBYTES.toSafeUInt32();

  @override
  int get keyBytes => sodium.crypto_kdf_KEYBYTES.toSafeUInt32();

  @override
  SecureKey keygen() => SecureKeyJS(
        sodium,
        jsErrorWrap(sodium.crypto_kdf_keygen),
      );

  @override
  SecureKey deriveFromKey({
    required SecureKey masterKey,
    required String context,
    required int subkeyId,
    required int subkeyLen,
  }) {
    validateMasterKey(masterKey);
    validateContext(context);
    validateSubkeyLen(subkeyLen);

    return SecureKeyJS(
      sodium,
      jsErrorWrap(
        () => masterKey.runUnlockedSync(
          (masterKeyData) => sodium.crypto_kdf_derive_from_key(
            subkeyLen,
            BigInt.from(subkeyId),
            context,
            masterKeyData,
          ),
        ),
      ),
    );
  }
}
