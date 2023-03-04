import 'dart:isolate';

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../api/key_pair.dart';
import '../../secure_key_ffi.dart';
import '../../sodium_ffi.dart';

part 'transferable_key_pair.freezed.dart';

/// @nodoc
@freezed
@internal
class TransferableKeyPair with _$TransferableKeyPair {
  /// @nodoc
  factory TransferableKeyPair(KeyPair keyPair) => keyPair.secretKey
          is SecureKeyFFI
      ? TransferableKeyPair.ffi(
          publicKeyBytes: TransferableTypedData.fromList([keyPair.publicKey]),
          secretKeyNativeHandle:
              (keyPair.secretKey as SecureKeyFFI).copy().detach(),
        )
      : TransferableKeyPair.generic(
          publicKeyBytes: TransferableTypedData.fromList([keyPair.publicKey]),
          secretKeyBytes: TransferableTypedData.fromList(
            [keyPair.secretKey.extractBytes()],
          ),
        );

  /// @nodoc
  const factory TransferableKeyPair.ffi({
    required TransferableTypedData publicKeyBytes,
    required SecureKeyFFINativeHandle secretKeyNativeHandle,
  }) = _TransferableKeyPairFFI;

  /// @nodoc
  const factory TransferableKeyPair.generic({
    required TransferableTypedData publicKeyBytes,
    required TransferableTypedData secretKeyBytes,
  }) = _TransferableKeyPairGeneric;

  const TransferableKeyPair._();

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
