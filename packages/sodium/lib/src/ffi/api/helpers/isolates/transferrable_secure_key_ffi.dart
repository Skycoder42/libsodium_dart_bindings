import 'dart:isolate';

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../api/secure_key.dart';
import '../../../../api/transferrable_secure_key.dart';
import '../../secure_key_ffi.dart';
import '../../sodium_ffi.dart';

part 'transferrable_secure_key_ffi.freezed.dart';

/// @nodoc
@freezed
@internal
sealed class TransferrableSecureKeyFFI
    with _$TransferrableSecureKeyFFI
    implements TransferrableSecureKey {
  /// @nodoc
  factory TransferrableSecureKeyFFI(SecureKey secureKey) =>
      secureKey is SecureKeyFFI
          ? TransferrableSecureKeyFFI.ffi(secureKey.copy().detach())
          : TransferrableSecureKeyFFI.generic(
              TransferableTypedData.fromList([secureKey.extractBytes()]),
            );

  /// @nodoc
  const factory TransferrableSecureKeyFFI.ffi(
    SecureKeyFFINativeHandle nativeHandle,
  ) = _TransferrableSecureKeyFFINative;

  /// @nodoc
  const factory TransferrableSecureKeyFFI.generic(
    TransferableTypedData keyBytes,
  ) = _TransferrableSecureKeyFFIGeneric;

  const TransferrableSecureKeyFFI._();

  /// @nodoc
  SecureKey toSecureKey(SodiumFFI sodium) => when(
        ffi: (handle) => SecureKeyFFI.attach(sodium.sodium, handle),
        generic: (data) => sodium.secureCopy(data.materialize().asUint8List()),
      );
}
