import 'dart:async';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../../../api/secure_key.dart';
import '../../../../api/sign.dart';
import '../../../../api/sodium_exception.dart';
import '../../../bindings/libsodium.ffi.dart';
import '../../../bindings/secure_key_native.dart';
import '../../../bindings/sodium_pointer.dart';
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
  SignatureConsumerFFI({
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
  Uint8List finalize(SodiumPointer<UnsignedChar> state) {
    final signaturePtr = SodiumPointer<UnsignedChar>.alloc(
      sodium,
      count: sodium.crypto_sign_bytes(),
      zeroMemory: true,
    );

    try {
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

      return Uint8List.fromList(signaturePtr.asListView());
    } finally {
      signaturePtr.dispose();
    }
  }
}
