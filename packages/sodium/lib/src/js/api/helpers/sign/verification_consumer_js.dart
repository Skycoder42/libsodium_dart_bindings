import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../../../api/sign.dart';
import '../../../bindings/js_error.dart';
import '../../../bindings/sodium.js.dart';
import 'sign_consumer_js_mixin.dart';

/// @nodoc
@internal
class VerificationConsumerJS
    with SignConsumerJSMixin<bool>
    implements VerificationConsumer {
  @override
  final LibSodiumJS sodium;

  /// @nodoc
  final Uint8List signature;

  /// @nodoc
  final Uint8List publicKey;

  /// @nodoc
  VerificationConsumerJS({
    required this.sodium,
    required this.signature,
    required this.publicKey,
  }) {
    initState();
  }

  @override
  Future<bool> get signatureValid => result;

  @override
  bool finalize(SignState state) => jsErrorWrap(
        () => sodium.crypto_sign_final_verify(
          state,
          signature,
          publicKey,
        ),
      );
}
