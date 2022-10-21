import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../../api/secure_key.dart';
import '../../../api/sumo/scalarmult_sumo.dart';
import '../../bindings/js_error.dart';
import '../../bindings/sodium.js.dart';
import '../../bindings/to_safe_int.dart';
import '../secure_key_js.dart';

/// @nodoc
@internal
class ScalarmultSumoJS
    with ScalarmultSumoValidations
    implements ScalarmultSumo {
  /// @nodoc
  final LibSodiumJS sodium;

  /// @nodoc
  ScalarmultSumoJS(this.sodium);

  @override
  int get bytes => sodium.crypto_scalarmult_BYTES.toSafeUInt32();

  @override
  int get scalarBytes => sodium.crypto_scalarmult_SCALARBYTES.toSafeUInt32();

  @override
  Uint8List base({required SecureKey n}) {
    validateSecretKey(n);

    return jsErrorWrap(
      () => n.runUnlockedSync(sodium.crypto_scalarmult_base),
    );
  }

  @override
  SecureKey call({
    required SecureKey n,
    required Uint8List p,
  }) {
    validateSecretKey(n);
    validatePublicKey(p);

    return SecureKeyJS(
      sodium,
      jsErrorWrap(
        () => n.runUnlockedSync(
          (nData) => sodium.crypto_scalarmult(nData, p),
        ),
      ),
    );
  }
}
