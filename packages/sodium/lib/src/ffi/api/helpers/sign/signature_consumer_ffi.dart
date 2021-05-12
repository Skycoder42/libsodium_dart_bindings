import 'dart:async';
import 'dart:ffi';
import 'dart:typed_data';

import '../../../../api/secure_key.dart';
import '../../../../api/sign.dart';
import '../../../../api/sodium_exception.dart';
import '../../../bindings/libsodium.ffi.dart';
import '../../../bindings/secure_key_native.dart';
import '../../../bindings/sodium_pointer.dart';
import 'sign_consumer_ffi_mixin.dart';

class SignatureConsumerFFI
    with SignConsumerFFIMixin<Uint8List>
    implements SignatureConsumer {
  @override
  final LibSodiumFFI sodium;

  late final SecureKey _secretKey;

  SignatureConsumerFFI.init({
    required this.sodium,
    required SecureKey secretKey,
  }) {
    _secretKey = secretKey.copy();
    try {
      initState();
    } catch (e) {
      _secretKey.dispose();
      rethrow;
    }
  }

  @override
  Future<Uint8List> get signature => result;

  @override
  Uint8List finalize(SodiumPointer<Uint8> state) {
    final signaturePtr = SodiumPointer<Uint8>.alloc(
      sodium,
      count: sodium.crypto_sign_bytes(),
      zeroMemory: true,
    );

    try {
      final result = _secretKey.runUnlockedNative(
        sodium,
        (secretKeyPtr) => sodium.crypto_sign_final_create(
          state.ptr.cast(),
          signaturePtr.ptr,
          nullptr,
          secretKeyPtr.ptr,
        ),
      );
      SodiumException.checkSucceededInt(result);

      return signaturePtr.copyAsList();
    } finally {
      signaturePtr.dispose();
    }
  }
}
