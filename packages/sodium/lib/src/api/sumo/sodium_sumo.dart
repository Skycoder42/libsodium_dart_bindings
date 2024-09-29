import 'dart:async';

import '../key_pair.dart';
import '../secure_key.dart';
import '../sodium.dart';
import 'crypto_sumo.dart';

/// A callback to be executed on a separate isolate.
///
/// The callback receives a fresh [sodium] sumo instance that only lives on the
/// new isolate, as well as the [secureKeys] and [keyPairs] that have been
/// transferred to it via the [SodiumSumo.runIsolated] method.
typedef SodiumSumoIsolateCallback<T> = FutureOr<T> Function(
  SodiumSumo sodium,
  List<SecureKey> secureKeys,
  List<KeyPair> keyPairs,
);

typedef SodiumSumoFactory = Future<SodiumSumo> Function();

/// A meta class that provides access to all toplevel libsodium sumo API groups.
abstract class SodiumSumo implements Sodium {
  const SodiumSumo._(); // coverage:ignore-line

  @override
  CryptoSumo get crypto;

  @override
  Future<T> runIsolated<T>(
    SodiumSumoIsolateCallback<T> callback, {
    List<SecureKey> secureKeys = const [],
    List<KeyPair> keyPairs = const [],
  });

  @override
  SodiumSumoFactory get isolateFactory;
}
