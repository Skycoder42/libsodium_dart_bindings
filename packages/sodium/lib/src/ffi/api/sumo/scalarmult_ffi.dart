import 'dart:ffi';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../../api/secure_key.dart';
import '../../../api/sodium_exception.dart';
import '../../../api/sumo/scalarmult.dart';
import '../../bindings/libsodium.ffi.wrapper.dart';
import '../../bindings/secure_key_native.dart';
import '../../bindings/sodium_scope.dart';

@internal
// ignore: public_member_api_docs false positive
class ScalarmultFFI(final LibSodiumFFI sodium)
    with ScalarmultValidations
    implements Scalarmult {
  @override
  int get bytes => sodium.crypto_scalarmult_bytes();

  @override
  int get scalarBytes => sodium.crypto_scalarmult_scalarbytes();

  @override
  Uint8List base({required SecureKey n}) {
    validateSecretKey(n);

    return sodiumScope(sodium, (scope) {
      final qPtr = scope.alloc<UnsignedChar>(bytes);

      final result = n.runUnlockedNative(
        sodium,
        (nPtr) => sodium.crypto_scalarmult_base(qPtr.ptr, nPtr.ptr),
      );
      SodiumException.checkSucceededInt(result);

      return scope.takeBytes(qPtr);
    });
  }

  @override
  SecureKey call({required SecureKey n, required Uint8List p}) {
    validateSecretKey(n);
    validatePublicKey(p);

    return sodiumScope(sodium, (scope) {
      final pPtr = scope.copyList<UnsignedChar>(p);
      final q = scope.allocSecureKey(bytes);

      final result = q.runUnlockedNative(
        (qPtr) => n.runUnlockedNative(
          sodium,
          (nPtr) => sodium.crypto_scalarmult(qPtr.ptr, nPtr.ptr, pPtr.ptr),
        ),
        writable: true,
      );
      SodiumException.checkSucceededInt(result);

      return scope.takeSecureKey(q);
    });
  }
}
