import 'dart:isolate';

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../api/secure_key.dart';
import '../../secure_key_ffi.dart';
import '../../sodium_ffi.dart';

part 'transferable_secure_key.freezed.dart';

/// @nodoc
@freezed
@internal
class TransferableSecureKey with _$TransferableSecureKey {
  /// @nodoc
  factory TransferableSecureKey(SecureKey secureKey) =>
      secureKey is SecureKeyFFI
          ? TransferableSecureKey.ffi(secureKey.nativeHandle)
          : TransferableSecureKey.generic(
              TransferableTypedData.fromList([secureKey.extractBytes()]),
            );

  /// @nodoc
  const factory TransferableSecureKey.ffi(
    SecureKeyFFINativeHandle nativeHandle,
  ) = _TransferableSecureKeyFFI;

  /// @nodoc
  const factory TransferableSecureKey.generic(TransferableTypedData keyBytes) =
      _TransferableSecureKeyGeneric;

  const TransferableSecureKey._();

  /// @nodoc
  SecureKey toSecureKey(SodiumFFI sodium) => when(
        ffi: (handle) => sodium.secureHandle(handle),
        generic: (data) => sodium.secureCopy(data.materialize().asUint8List()),
      );
}
