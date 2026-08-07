import 'dart:async';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../../../api/secure_key.dart';
import '../../../../api/sign.dart';
import '../../../../api/sodium_exception.dart';
import '../../../bindings/libsodium.ffi.wrapper.dart';
import '../../../bindings/secure_key_native.dart';
import '../../../bindings/sodium_pointer.dart';
import '../../../bindings/sodium_scope.dart';
import 'sign_consumer_ffi_mixin.dart';

/// @nodoc
@internal
class SignatureConsumerFFI
    with SignConsumerFFIMixin<Uint8List>
    implements SignatureConsumer {
  @override
  final LibSodiumFFI sodium;

  /// @nodoc
  late final SecureKey secretKey;

  /// @nodoc
  SignatureConsumerFFI({required this.sodium, required SecureKey secretKey}) {
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
  Uint8List finalize(SodiumPointer<UnsignedChar> state) =>
      sodiumScope(sodium, (scope) {
        final signaturePtr = scope.alloc<UnsignedChar>(
          sodium.crypto_sign_bytes(),
          zeroMemory: true,
        );

        final result = secretKey.runUnlockedNative(
          sodium,
          (secretKeyPtr) => sodium.crypto_sign_final_create(
            state.ptr.cast(),
            signaturePtr.ptr,
            nullptr,
            secretKeyPtr.ptr,
          ),
        );
        SodiumException.checkSucceededInt(result);

        return scope.takeBytes(signaturePtr);
      });
}
