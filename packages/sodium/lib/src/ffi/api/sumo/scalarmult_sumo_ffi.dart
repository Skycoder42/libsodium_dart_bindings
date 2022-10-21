import 'dart:ffi';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../../api/secure_key.dart';
import '../../../api/sodium_exception.dart';
import '../../../api/sumo/scalarmult_sumo.dart';
import '../../bindings/libsodium.ffi.dart';
import '../../bindings/memory_protection.dart';
import '../../bindings/secure_key_native.dart';
import '../../bindings/sodium_pointer.dart';
import '../secure_key_ffi.dart';

/// @nodoc
@internal
class ScalarmultSumoFFI
    with ScalarmultSumoValidations
    implements ScalarmultSumo {
  /// @nodoc
  final LibSodiumFFI sodium;

  /// @nodoc
  ScalarmultSumoFFI(this.sodium);

  @override
  int get bytes => sodium.crypto_scalarmult_bytes();

  @override
  int get scalarBytes => sodium.crypto_scalarmult_scalarbytes();

  @override
  Uint8List base({required SecureKey n}) {
    validateSecretKey(n);

    SodiumPointer<UnsignedChar>? qPtr;
    try {
      qPtr = SodiumPointer.alloc(
        sodium,
        count: bytes,
      );

      final result = n.runUnlockedNative(
        sodium,
        (nPtr) => sodium.crypto_scalarmult_base(qPtr!.ptr, nPtr.ptr),
      );
      SodiumException.checkSucceededInt(result);

      return Uint8List.fromList(qPtr.asListView());
    } finally {
      qPtr?.dispose();
    }
  }

  @override
  SecureKey call({
    required SecureKey n,
    required Uint8List p,
  }) {
    validateSecretKey(n);
    validatePublicKey(p);

    SodiumPointer<UnsignedChar>? pPtr;
    SecureKeyFFI? q;
    try {
      pPtr = p.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );
      q = SecureKeyFFI.alloc(sodium, bytes);

      final result = q.runUnlockedNative(
        (qPtr) => n.runUnlockedNative(
          sodium,
          (nPtr) => sodium.crypto_scalarmult(
            qPtr.ptr,
            nPtr.ptr,
            pPtr!.ptr,
          ),
        ),
        writable: true,
      );
      SodiumException.checkSucceededInt(result);

      return q;
    } catch (e) {
      q?.dispose();
      rethrow;
    } finally {
      pPtr?.dispose();
    }
  }
}
