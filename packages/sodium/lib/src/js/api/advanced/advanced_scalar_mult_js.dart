import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:sodium/src/js/api/secure_key_js.dart';

import '../../../../sodium.js.dart';
import '../../../api/advanced/advanced_scalar_mult.dart';
import '../../../api/secure_key.dart';

@internal
class AdvancedScalarMultJS
    with AdvancedScalarMultValidations
    implements AdvancedScalarMult {
  final LibSodiumJS sodium;

  AdvancedScalarMultJS(this.sodium);

  @override
  int get bytes => sodium.crypto_scalarmult_BYTES.toSafeUInt32();

  @override
  int get scalarBytes => sodium.crypto_scalarmult_SCALARBYTES.toSafeUInt32();

  @override
  Uint8List base({required SecureKey secretKey}) {
    validateSecretKey(secretKey);
    return JsError.wrap(
      () => secretKey.runUnlockedSync(
        (secretKeyData) => sodium.crypto_scalarmult_base(secretKeyData),
      ),
    );
  }

  @override
  SecureKey call({
    required SecureKey secretKey,
    required Uint8List otherPublicKey,
  }) {
    validateSecretKey(secretKey);
    validatePublicKey(otherPublicKey);

    final sharedSecret = JsError.wrap(
      () => secretKey.runUnlockedSync(
        (secretKeyData) => sodium.crypto_scalarmult(
          secretKeyData,
          otherPublicKey,
        ),
        writable: true,
      ),
    );

    return SecureKeyJS(sodium, sharedSecret);
  }
}
