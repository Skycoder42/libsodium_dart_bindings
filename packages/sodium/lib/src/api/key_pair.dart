import 'dart:typed_data';

import 'package:meta/meta.dart';

import 'secure_key.dart';

/// A pair of keys that belong together. Consists of a [secretKey] as well as
/// the corresponding [publicKey].
@immutable
class KeyPair {
  /// The public key of the key pair.
  final Uint8List publicKey;

  /// The secret key of the key pair.
  final SecureKey secretKey;

  /// Default constructor.
  const KeyPair({
    required this.publicKey,
    required this.secretKey,
  });

  /// Creates a copy of this key.
  KeyPair copy() => KeyPair(
        publicKey: Uint8List.fromList(publicKey),
        secretKey: secretKey.copy(),
      );

  /// Disposes the [secretKey] wrapped by this key pair.
  void dispose() => secretKey.dispose();
}
