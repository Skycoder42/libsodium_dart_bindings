import 'dart:async';

import '../sodium.dart';
import 'crypto_sumo.dart';

/// A factory method that creates new [SodiumSumo] instances. This factory can
/// be passed between isolates and can be used if custom isolate handling is
/// required.
typedef SodiumSumoFactory = Future<SodiumSumo> Function();

/// A meta class that provides access to all toplevel libsodium sumo API groups.
abstract class SodiumSumo implements Sodium {
  const SodiumSumo._(); // coverage:ignore-line

  @override
  CryptoSumo get crypto;
}
