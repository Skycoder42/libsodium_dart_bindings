import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

import 'secure_key.dart';

part 'key_pair.freezed.dart';

/// A pair of keys that belong together. Consists of a [secretKey] as well as
/// the corresponding [publicKey].
@Freezed(copyWith: false)
sealed class KeyPair with _$KeyPair {
  /// Default constructor.
  factory KeyPair({
    /// The public key of the key pair.
    required Uint8List publicKey,

    /// The secret key of the key pair.
    required SecureKey secretKey,
  }) = _KeyPair;

  KeyPair._();

  /// Creates a copy of this key.
  KeyPair copy() => KeyPair(
        publicKey: Uint8List.fromList(publicKey),
        secretKey: secretKey.copy(),
      );

  /// Disposes the [secretKey] wrapped by this key pair.
  void dispose() => secretKey.dispose();
}
