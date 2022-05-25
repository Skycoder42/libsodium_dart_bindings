import 'dart:async';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../../../api/secure_key.dart';
import '../../../../api/sign.dart';
import '../../../bindings/js_error.dart';
import '../../../bindings/sodium.js.dart';
import 'sign_consumer_js_mixin.dart';

/// @nodoc
@internal
class SignatureConsumerJS
    with SignConsumerJSMixin<Uint8List>
    implements SignatureConsumer {
  @override
  final LibSodiumJS sodium;

  /// @nodoc
  late final SecureKey secretKey;

  /// @nodoc
  SignatureConsumerJS({
    required this.sodium,
    required SecureKey secretKey,
  }) {
    this.secretKey = secretKey.copy();
    try {
      initState();
    } catch (e) {
      this.secretKey.dispose();
      rethrow;
    }
  }

  @override
  Future<Uint8List> get signature => result;

  @override
  Uint8List finalize(SignState state) => JsError.wrap(
        () => secretKey.runUnlockedSync(
          (secretKeyData) => sodium.crypto_sign_final_create(
            state,
            secretKeyData,
          ),
        ),
      );
}
