import '../sodium.dart';
import 'crypto_sumo.dart';

/// A meta class that provides access to all toplevel libsodium sumo API groups.
abstract class SodiumSumo implements Sodium {
  const SodiumSumo._(); // coverage:ignore-line

  @override
  CryptoSumo get crypto;
}
