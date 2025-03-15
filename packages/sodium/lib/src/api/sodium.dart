import 'dart:async';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import 'crypto.dart';
import 'key_pair.dart';
import 'randombytes.dart';
import 'secure_key.dart';
import 'sodium_version.dart';
import 'transferrable_secure_key.dart';

/// A callback to be executed on a separate isolate.
///
/// The callback receives a fresh [sodium] instance that only lives on the
/// new isolate, as well as the [secureKeys] and [keyPairs] that have been
/// transferred to it via the [Sodium.runIsolated] method.
typedef SodiumIsolateCallback<T> =
    FutureOr<T> Function(
      Sodium sodium,
      List<SecureKey> secureKeys,
      List<KeyPair> keyPairs,
    );

/// A factory method that creates new [Sodium] instances. This factory can be
/// passed between isolates and can be used if custom isolate handling is
/// required.
typedef SodiumFactory = Future<Sodium> Function();

/// A meta class that provides access to all toplevel libsodium API groups.
abstract class Sodium {
  const Sodium._(); // coverage:ignore-line

  /// Returns the version of the underlying libsodium implementation.
  SodiumVersion get version;

  /// Provides sodium_pad.
  ///
  /// See https://libsodium.gitbook.io/doc/padding#usage
  Uint8List pad(Uint8List buf, int blocksize);

  /// Provides sodium_unpad.
  ///
  /// See https://libsodium.gitbook.io/doc/padding#usage
  Uint8List unpad(Uint8List buf, int blocksize);

  /// Allocates new memory for a [SecureKey] of [length] bytes.
  @useResult
  SecureKey secureAlloc(int length);

  /// Allocates new memory for a [SecureKey] and fills it with [length] bytes of
  /// random data.
  @useResult
  SecureKey secureRandom(int length);

  /// Allocates new memory for a [SecureKey] and copies the data from [data].
  @useResult
  SecureKey secureCopy(Uint8List data);

  /// An instance of [Randombytes].
  ///
  /// This provides all APIs that start with `randombytes`.
  Randombytes get randombytes;

  /// An instance of [Crypto].
  ///
  /// This provides all APIs that start with `crypto`.
  Crypto get crypto;

  /// Runs the given [callback] with an isolate.
  ///
  /// This method can be used to run computation heavy tasks within a separate
  /// isolate.
  ///
  /// **Important:** [SecureKey]s and [KeyPair]s cannot be passed to the isolate
  /// via context. Instead you have to pass them as array via the [secureKeys]
  /// and [keyPairs] parameters to this method and can then retrieve them via
  /// the `secureKeys` and `keyPairs` arguments of the callback. They will be
  /// passed to the callback in the same order in that they were passed to the
  /// arguments of this method.
  ///
  /// In case you need more control over the isolates, you can use
  /// [isolateFactory] to get a factory method that can be passed between
  /// isolates.
  Future<T> runIsolated<T>(
    SodiumIsolateCallback<T> callback, {
    List<SecureKey> secureKeys = const [],
    List<KeyPair> keyPairs = const [],
  });

  // The following are the raw isolate APIs

  /// Retrieves a factory method to create new sodium instances that use the
  /// same native binaries.
  ///
  /// This is meant to be used to obtain a factory that can be passed between
  /// isolates. Usually, you would use [runIsolated] for isolated computation.
  /// However, sometimes you need more control over the isolates. In this case
  /// you can use this method to get a [Sodium] instance on a separate isolate.
  SodiumFactory get isolateFactory;

  /// Creates a boxed copy of the [secureKey] that can be transferred between
  /// isolates.
  ///
  /// **DANGEROUS**: This method is dangerous, as it leaves you with raw native
  /// handles! See [TransferrableSecureKey] for more details on how to use this
  /// API.
  @useResult
  TransferrableSecureKey createTransferrableSecureKey(SecureKey secureKey);

  /// Extracts the [SecureKey] from the [transferrableSecureKey].
  ///
  /// After calling this method, the [TransferrableSecureKey] becomes invalid
  /// and cannot be used again.
  ///
  /// **DANGEROUS**: This method is dangerous, as it leaves you with raw native
  /// handles! See [TransferrableSecureKey] for more details on how to use this
  /// API.
  @useResult
  SecureKey materializeTransferrableSecureKey(
    TransferrableSecureKey transferrableSecureKey,
  );

  /// Creates a boxed copy of the [keyPair] that can be transferred between
  /// isolates.
  ///
  /// **DANGEROUS**: This method is dangerous, as it leaves you with raw native
  /// handles! See [TransferrableKeyPair] for more details on how to use this
  /// API.
  @useResult
  TransferrableKeyPair createTransferrableKeyPair(KeyPair keyPair);

  /// Extracts the [KeyPair] from the [transferrableKeyPair].
  ///
  /// After calling this method, the [TransferrableKeyPair] becomes invalid
  /// and cannot be used again.
  ///
  /// **DANGEROUS**: This method is dangerous, as it leaves you with raw native
  /// handles! See [TransferrableKeyPair] for more details on how to use this
  /// API.
  @useResult
  KeyPair materializeTransferrableKeyPair(
    TransferrableKeyPair transferrableKeyPair,
  );
}
