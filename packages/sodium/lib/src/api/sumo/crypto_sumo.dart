import '../crypto.dart';
import 'pwhash.dart';
import 'scalarmult.dart';
import 'sign_sumo.dart';

/// A meta class that provides access to all libsodium sumo crypto APIs.
abstract interface class const CryptoSumo._() implements Crypto {
  @override
  SignSumo get sign;

  /// An instance of [Pwhash].
  ///
  /// This provides all APIs that start with `crypto_pwhash`.
  Pwhash get pwhash;

  /// An instance of [Scalarmult].
  ///
  /// This provides all APIs that start with `crypto_scalarmult`.
  Scalarmult get scalarmult;
}
