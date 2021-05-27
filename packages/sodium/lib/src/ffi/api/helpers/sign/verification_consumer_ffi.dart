import 'dart:async';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../../../api/sign.dart';
import '../../../bindings/libsodium.ffi.dart';
import '../../../bindings/memory_protection.dart';
import '../../../bindings/sodium_pointer.dart';
import 'sign_consumer_ffi_mixin.dart';

@internal
class VerificationConsumerFFI
    with SignConsumerFFIMixin<bool>
    implements VerificationConsumer {
  @override
  final LibSodiumFFI sodium;

  final Uint8List signature;
  final Uint8List publicKey;

  VerificationConsumerFFI({
    required this.sodium,
    required this.signature,
    required this.publicKey,
  }) {
    initState();
  }

  @override
  Future<bool> get signatureValid => result;

  @override
  bool finalize(SodiumPointer<Uint8> state) {
    SodiumPointer<Uint8>? signaturePtr;
    SodiumPointer<Uint8>? publicKeyPtr;

    try {
      signaturePtr = signature.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );
      publicKeyPtr = publicKey.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );

      final result = sodium.crypto_sign_final_verify(
        state.ptr.cast(),
        signaturePtr.ptr,
        publicKeyPtr.ptr,
      );

      return result == 0;
    } finally {
      signaturePtr?.dispose();
      publicKeyPtr?.dispose();
    }
  }
}
