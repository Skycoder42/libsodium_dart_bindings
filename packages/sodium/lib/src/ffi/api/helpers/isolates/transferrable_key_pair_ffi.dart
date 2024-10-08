import 'dart:isolate';

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../api/key_pair.dart';
import '../../../../api/transferrable_secure_key.dart';
import '../../secure_key_ffi.dart';
import '../../sodium_ffi.dart';

part 'transferrable_key_pair_ffi.freezed.dart';

/// @nodoc
@freezed
@internal
sealed class TransferrableKeyPairFFI
    with _$TransferrableKeyPairFFI
    implements TransferrableKeyPair {
  /// @nodoc
  factory TransferrableKeyPairFFI(KeyPair keyPair) => keyPair.secretKey
          is SecureKeyFFI
      ? TransferrableKeyPairFFI.ffi(
          publicKeyBytes: TransferableTypedData.fromList([keyPair.publicKey]),
          secretKeyNativeHandle:
              (keyPair.secretKey as SecureKeyFFI).copy().detach(),
        )
      : TransferrableKeyPairFFI.generic(
          publicKeyBytes: TransferableTypedData.fromList([keyPair.publicKey]),
          secretKeyBytes: TransferableTypedData.fromList(
            [keyPair.secretKey.extractBytes()],
          ),
        );

  /// @nodoc
  const factory TransferrableKeyPairFFI.ffi({
    required TransferableTypedData publicKeyBytes,
    required SecureKeyFFINativeHandle secretKeyNativeHandle,
  }) = _TransferrableKeyPairFFINative;

  /// @nodoc
  const factory TransferrableKeyPairFFI.generic({
    required TransferableTypedData publicKeyBytes,
    required TransferableTypedData secretKeyBytes,
  }) = _TransferrableKeyPairFFIGeneric;

  const TransferrableKeyPairFFI._();

  /// @nodoc
  KeyPair toKeyPair(SodiumFFI sodium) => when(
        ffi: (publicKeyData, secretKeyHandle) => KeyPair(
          publicKey: publicKeyData.materialize().asUint8List(),
          secretKey: SecureKeyFFI.attach(sodium.sodium, secretKeyHandle),
        ),
        generic: (publicKeyData, secretKeyData) => KeyPair(
          publicKey: publicKeyData.materialize().asUint8List(),
          secretKey: sodium.secureCopy(
            secretKeyData.materialize().asUint8List(),
          ),
        ),
      );
}
