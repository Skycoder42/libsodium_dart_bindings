import 'dart:async';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../../../api/sign.dart';
import '../../../bindings/libsodium.ffi.wrapper.dart';
import '../../../bindings/sodium_pointer.dart';
import '../../../bindings/sodium_scope.dart';
import 'sign_consumer_ffi_mixin.dart';

@internal
class VerificationConsumerFFI({
  @override required final LibSodiumFFI sodium,
  required final Uint8List signature,
  required final Uint8List publicKey,
}) with SignConsumerFFIMixin<bool> implements VerificationConsumer {
  this {
    initState();
  }

  @override
  Future<bool> get signatureValid => result;

  @override
  bool finalize(SodiumPointer<UnsignedChar> state) =>
      sodiumScope(sodium, (scope) {
        final signaturePtr = scope.copyList<UnsignedChar>(signature);
        final publicKeyPtr = scope.copyList<UnsignedChar>(publicKey);

        final result = sodium.crypto_sign_final_verify(
          state.ptr.cast(),
          signaturePtr.ptr,
          publicKeyPtr.ptr,
        );

        return result == 0;
      });
}
