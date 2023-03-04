import 'dart:async';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import 'crypto.dart';
import 'key_pair.dart';
import 'randombytes.dart';
import 'secure_key.dart';
import 'sodium_version.dart';

/// A callback to be executed on a separate isolate.
///
/// The callback receives a fresh [sodium] instance that only lives on the
/// new isolate, as well as the [secureKeys] and [keyPairs] that have been
/// transferred to it via the [Sodium.runIsolated] method.
typedef SodiumIsolateCallback<T> = FutureOr<T> Function(
  Sodium sodium,
  List<SecureKey> secureKeys,
  List<KeyPair> keyPairs,
);

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
  SecureKey secureAlloc(int length);

  /// Allocates new memory for a [SecureKey] and fills it with [length] bytes of
  /// random data.
  SecureKey secureRandom(int length);

  /// Allocates new memory for a [SecureKey] and copies the data from [data].
  SecureKey secureCopy(Uint8List data);

  /// Creates a secure key from a previously extracted [SecureKey.nativeHandle].
  ///
  /// > Dangerous API. Only use if you have no other choice and you know what
  /// you are doing. You have been warned!
  ///
  /// Creating such a secure key will *not* create a copy of it, but instead
  /// operate on the same low-level data. This means, if you take the handle
  /// from one key and create a new one using this method, both [SecureKey]
  /// instances will point to the same data.
  ///
  /// **Important:** Since multiple keys to the same handle all operate on the
  /// same data, disposing one will dispose all, and changes to one immediatly
  /// are reflected to the others. When using a handle across isolate
  /// boundaries, make sure the different isolates never access the key at the
  /// same time, as that might break the native code.
  @experimental
  SecureKey secureHandle(dynamic nativeHandle);

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
  Future<T> runIsolated<T>(
    SodiumIsolateCallback<T> callback, {
    List<SecureKey> secureKeys = const [],
    List<KeyPair> keyPairs = const [],
  });
}
