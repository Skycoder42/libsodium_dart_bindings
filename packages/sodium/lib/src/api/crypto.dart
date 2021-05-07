import 'pwhash.dart';
import 'secret_box.dart';
import 'secret_stream.dart';

/// A meta class that provides access to all libsodium crypto APIs.
abstract class Crypto {
  const Crypto._(); // coverage:ignore-line

  /// An instance of [SecretBox].
  ///
  /// This provides all APIs that start with `crypto_secretbox`.
  SecretBox get secretBox;

  /// An instance of [SecretStream].
  ///
  /// This provides all APIs that start with `crypto_secretstream`.
  SecretStream get secretStream;

  /// An instance of [Pwhash].
  ///
  /// This provides all APIs that start with `crypto_pwhash`.
  Pwhash get pwhash;
}
