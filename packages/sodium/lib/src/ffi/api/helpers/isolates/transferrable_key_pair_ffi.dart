import 'dart:isolate';

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../api/key_pair.dart';
import '../../../../api/transferrable_secure_key.dart';
import '../../secure_key_ffi.dart';
import '../../sodium_ffi.dart';

part 'transferrable_key_pair_ffi.freezed.dart';

@freezed
@internal
sealed class const TransferrableKeyPairFFI._()
    with _$TransferrableKeyPairFFI
    implements TransferrableKeyPair {
  factory(KeyPair keyPair) => keyPair.secretKey is SecureKeyFFI
      ? TransferrableKeyPairFFI.ffi(
          publicKeyBytes: TransferableTypedData.fromList([keyPair.publicKey]),
          secretKeyNativeHandle: (keyPair.secretKey as SecureKeyFFI)
              .copy()
              .detach(),
        )
      : TransferrableKeyPairFFI.generic(
          publicKeyBytes: TransferableTypedData.fromList([keyPair.publicKey]),
          secretKeyBytes: TransferableTypedData.fromList([
            keyPair.secretKey.extractBytes(),
          ]),
        );

  const factory ffi({
    required TransferableTypedData publicKeyBytes,
    required SecureKeyFFINativeHandle secretKeyNativeHandle,
  }) = TransferrableKeyPairFFINative;

  const factory generic({
    required TransferableTypedData publicKeyBytes,
    required TransferableTypedData secretKeyBytes,
  }) = TransferrableKeyPairFFIGeneric;

  KeyPair toKeyPair(SodiumFFI sodium) => switch (this) {
    TransferrableKeyPairFFINative(
      :final publicKeyBytes,
      :final secretKeyNativeHandle,
    ) =>
      KeyPair(
        publicKey: publicKeyBytes.materialize().asUint8List(),
        secretKey: SecureKeyFFI.attach(sodium.sodium, secretKeyNativeHandle),
      ),
    TransferrableKeyPairFFIGeneric(
      :final publicKeyBytes,
      :final secretKeyBytes,
    ) =>
      KeyPair(
        publicKey: publicKeyBytes.materialize().asUint8List(),
        secretKey: sodium.secureCopy(
          secretKeyBytes.materialize().asUint8List(),
        ),
      ),
  };
}
