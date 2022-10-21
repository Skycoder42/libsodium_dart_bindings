import '../crypto.dart';
import 'scalarmult_sumo.dart';
import 'sign_sumo.dart';

/// A meta class that provides access to all libsodium sumo crypto APIs.
abstract class CryptoSumo implements Crypto {
  const CryptoSumo._(); // coverage:ignore-line

  @override
  SignSumo get sign;

  /// An instance of [ScalarmultSumo].
  ///
  /// This provides all APIs that start with `crypto_scalarmult`.
  ScalarmultSumo get scalarmult;
}
