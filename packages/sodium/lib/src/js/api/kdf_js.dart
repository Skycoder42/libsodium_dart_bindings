// ignore_for_file: unnecessary_lambdas to catch member access errors

import 'dart:js_interop';

import 'package:meta/meta.dart';

import '../../api/kdf.dart';
import '../../api/secure_key.dart';
import '../bindings/js_big_int_x.dart';
import '../bindings/js_error.dart';
import '../bindings/sodium.js.dart';
import 'secure_key_js.dart';

/// @nodoc
@internal
class KdfJS with KdfValidations implements Kdf {
  /// @nodoc
  final LibSodiumJS sodium;

  /// @nodoc
  KdfJS(this.sodium);

  @override
  int get bytesMin => sodium.crypto_kdf_BYTES_MIN;

  @override
  int get bytesMax => sodium.crypto_kdf_BYTES_MAX;

  @override
  int get contextBytes => sodium.crypto_kdf_CONTEXTBYTES;

  @override
  int get keyBytes => sodium.crypto_kdf_KEYBYTES;

  @override
  SecureKey keygen() =>
      SecureKeyJS(sodium, jsErrorWrap(() => sodium.crypto_kdf_keygen()));

  @override
  SecureKey deriveFromKey({
    required SecureKey masterKey,
    required String context,
    required BigInt subkeyId,
    required int subkeyLen,
  }) {
    validateMasterKey(masterKey);
    final expandedContext = _expandContext(context);
    validateSubkeyId(subkeyId);
    validateSubkeyLen(subkeyLen);

    return SecureKeyJS(
      sodium,
      jsErrorWrap(
        () => masterKey.runUnlockedSync(
          (masterKeyData) => sodium.crypto_kdf_derive_from_key(
            subkeyLen,
            subkeyId.toJS,
            expandedContext,
            masterKeyData.toJS,
          ),
        ),
      ),
    );
  }

  String _expandContext(String context) {
    final len = validateContext(context);
    final missingBytes = contextBytes - len;
    if (missingBytes > 0) {
      final buffer = StringBuffer(context);
      for (var i = 0; i < missingBytes; ++i) {
        buffer.writeCharCode(0);
      }
      return buffer.toString();
    } else {
      return context;
    }
  }
}
