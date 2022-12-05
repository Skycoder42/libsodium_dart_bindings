import 'dart:ffi';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/auth.dart';
import '../../api/secure_key.dart';
import '../../api/sodium_exception.dart';
import '../bindings/libsodium.ffi.dart';
import '../bindings/memory_protection.dart';
import '../bindings/secure_key_native.dart';
import '../bindings/sodium_pointer.dart';
import 'helpers/keygen_mixin.dart';

/// @nodoc
@internal
class AuthFFI with AuthValidations, KeygenMixin implements Auth {
  /// @nodoc
  final LibSodiumFFI sodium;

  /// @nodoc
  AuthFFI(this.sodium);

  @override
  int get bytes => sodium.crypto_auth_bytes();

  @override
  int get keyBytes => sodium.crypto_auth_keybytes();

  @override
  SecureKey keygen() => keygenImpl(
        sodium: sodium,
        keyBytes: keyBytes,
        implementation: sodium.crypto_auth_keygen,
      );

  @override
  @pragma('vm:entry-point')
  Uint8List call({
    required Uint8List message,
    required SecureKey key,
  }) {
    validateKey(key);

    SodiumPointer<UnsignedChar>? messagePtr;
    SodiumPointer<UnsignedChar>? tagPtr;
    try {
      messagePtr = message.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );
      tagPtr = SodiumPointer.alloc(sodium, count: bytes);

      final result = key.runUnlockedNative(
        sodium,
        (keyPtr) => sodium.crypto_auth(
          tagPtr!.ptr,
          messagePtr!.ptr,
          messagePtr.count,
          keyPtr.ptr,
        ),
      );
      SodiumException.checkSucceededInt(result);

      return Uint8List.fromList(tagPtr.asListView());
    } finally {
      messagePtr?.dispose();
      tagPtr?.dispose();
    }
  }

  @override
  bool verify({
    required Uint8List tag,
    required Uint8List message,
    required SecureKey key,
  }) {
    validateTag(tag);
    validateKey(key);

    SodiumPointer<UnsignedChar>? messagePtr;
    SodiumPointer<UnsignedChar>? tagPtr;
    try {
      tagPtr = tag.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );
      messagePtr = message.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );

      final result = key.runUnlockedNative(
        sodium,
        (keyPtr) => sodium.crypto_auth_verify(
          tagPtr!.ptr,
          messagePtr!.ptr,
          messagePtr.count,
          keyPtr.ptr,
        ),
      );

      return result == 0;
    } finally {
      messagePtr?.dispose();
      tagPtr?.dispose();
    }
  }
}
