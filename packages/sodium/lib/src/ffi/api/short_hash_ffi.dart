import 'dart:ffi';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/secure_key.dart';
import '../../api/short_hash.dart';
import '../../api/sodium_exception.dart';
import '../bindings/libsodium.ffi.dart';
import '../bindings/memory_protection.dart';
import '../bindings/secure_key_native.dart';
import '../bindings/sodium_pointer.dart';
import 'helpers/keygen_mixin.dart';

/// @nodoc
@internal
class ShortHashFFI with ShortHashValidations, KeygenMixin implements ShortHash {
  /// @nodoc
  final LibSodiumFFI sodium;

  /// @nodoc
  ShortHashFFI(this.sodium);

  @override
  int get bytes => sodium.crypto_shorthash_bytes();

  @override
  int get keyBytes => sodium.crypto_shorthash_keybytes();

  @override
  SecureKey keygen() => keygenImpl(
    sodium: sodium,
    keyBytes: keyBytes,
    implementation: sodium.crypto_shorthash_keygen,
  );

  @override
  @pragma('vm:entry-point')
  Uint8List call({required Uint8List message, required SecureKey key}) {
    validateKey(key);

    SodiumPointer<UnsignedChar>? messagePtr;
    SodiumPointer<UnsignedChar>? outPtr;
    try {
      outPtr = SodiumPointer.alloc(sodium, count: bytes);
      messagePtr = message.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );

      final result = key.runUnlockedNative(
        sodium,
        (keyPtr) => sodium.crypto_shorthash(
          outPtr!.ptr,
          messagePtr!.ptr,
          messagePtr.count,
          keyPtr.ptr,
        ),
      );
      SodiumException.checkSucceededInt(result);

      return outPtr.asListView(owned: true);
    } catch (_) {
      outPtr?.dispose();
      rethrow;
    } finally {
      messagePtr?.dispose();
    }
  }
}
