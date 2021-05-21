// coverage:ignore-file
import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

import 'secure_key.dart';

part 'key_pair.freezed.dart';

/// A pair of keys that belong together. Consists of a [secretKey] as well as
/// the corresponding [publicKey].
@freezed
class KeyPair with _$KeyPair {
  /// Default constructor.
  const factory KeyPair({
    /// The secret key of the key pair.
    required SecureKey secretKey,

    /// The public key of the key pair.
    required Uint8List publicKey,
  }) = _KeyPair;
}
