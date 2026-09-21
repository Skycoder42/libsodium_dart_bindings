import 'dart:js_interop';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../../../api/sign.dart';
import '../../../bindings/js_error.dart';
import '../../../bindings/sodium.js.dart';
import 'sign_consumer_js_mixin.dart';

@internal
class VerificationConsumerJS({
  @override required final LibSodiumJS sodium,
  required final Uint8List signature,
  required final Uint8List publicKey,
}) with SignConsumerJSMixin<bool> implements VerificationConsumer {
  this {
    initState();
  }

  @override
  Future<bool> get signatureValid => result;

  @override
  bool finalize(SignState state) => jsErrorWrap(
    () =>
        sodium.crypto_sign_final_verify(state, signature.toJS, publicKey.toJS),
  );
}
