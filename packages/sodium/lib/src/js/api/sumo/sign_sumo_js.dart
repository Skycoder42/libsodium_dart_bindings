import 'dart:js_interop';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../../api/secure_key.dart';
import '../../../api/sumo/sign_sumo.dart';
import '../../bindings/js_error.dart';
import '../secure_key_js.dart';
import '../sign_js.dart';

/// @nodoc
@internal
class SignSumoJS extends SignJS implements SignSumo {
  /// @nodoc
  SignSumoJS(super.sodium);

  @override
  SecureKey skToSeed(SecureKey secretKey) {
    validateSecretKey(secretKey);

    return jsErrorWrap(
      () => secretKey.runUnlockedSync(
        (secretKeyData) => SecureKeyJS(
          sodium,
          sodium.crypto_sign_ed25519_sk_to_seed(secretKeyData.toJS),
        ),
      ),
    );
  }

  @override
  Uint8List skToPk(SecureKey secretKey) {
    validateSecretKey(secretKey);

    return jsErrorWrap(
      () => secretKey.runUnlockedSync(
        (keyData) => sodium.crypto_sign_ed25519_sk_to_pk(keyData.toJS).toDart,
      ),
    );
  }

  @override
  Uint8List pkToCurve25519(Uint8List publicKey) {
    validatePublicKey(publicKey);

    return jsErrorWrap(
      () => sodium.crypto_sign_ed25519_pk_to_curve25519(publicKey),
    );
  }

  @override
  Uint8List skToCurve25519(SecureKey secretKey) {
    validateSecretKey(secretKey);

    return jsErrorWrap(
      () => secretKey.runUnlockedSync(
        sodium.crypto_sign_ed25519_sk_to_curve25519,
      ),
    );
  }
}
