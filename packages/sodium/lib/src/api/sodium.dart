/// @docImport 'dart:io';
/// @docImport 'sodium_exception.dart';
library;

import 'dart:async';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import 'crypto.dart';
import 'helpers/platform_types/internet_address_fallback.dart'
    if (dart.library.io) 'helpers/platform_types/internet_address_io.dart'
    as ia;
import 'helpers/validations.dart';
import 'ip_address.dart';
import 'key_pair.dart';
import 'randombytes.dart';
import 'secure_key.dart';
import 'sodium_version.dart';
import 'transferrable_secure_key.dart';

/// A callback to be executed on a separate isolate.
///
/// The callback receives the [secureKeys] and [keyPairs] that have been
/// transferred to it via the [Sodium.runIsolated] method.
typedef SodiumIsolateCallback<T> = FutureOr<T> Function(
  List<SecureKey> secureKeys,
  List<KeyPair> keyPairs,
);

/// A meta class that provides access to all toplevel libsodium API groups.
abstract class Sodium {
  const new _(); // coverage:ignore-line

  /// Returns the version of the underlying libsodium implementation.
  SodiumVersion get version;

  /// Provides sodium_pad.
  ///
  /// See https://libsodium.gitbook.io/doc/padding#usage
  @useResult
  Uint8List pad(Uint8List buf, int blocksize);

  /// Provides sodium_unpad.
  ///
  /// See https://libsodium.gitbook.io/doc/padding#usage
  @useResult
  Uint8List unpad(Uint8List buf, int blocksize);

  /// Provides sodium_memcmp.
  ///
  /// Compares [b1] and [b2] in constant time and returns whether both buffers
  /// hold the same data. Both buffers must have the same length.
  ///
  /// Unlike [compare], this method is a pure equality check that does not leak
  /// any information about the contents of the buffers.
  ///
  /// See https://libsodium.gitbook.io/doc/helpers#constant-time-test-for-equality
  @useResult
  bool memcmp(Uint8List b1, Uint8List b2);

  /// Provides sodium_compare.
  ///
  /// Compares [b1] and [b2] in constant time, interpreting both as
  /// little-endian encoded, unsigned numbers. Returns `-1` if [b1] is smaller
  /// than [b2], `0` if both are equal and `1` if [b1] is greater than [b2].
  /// Both buffers must have the same length.
  ///
  /// See https://libsodium.gitbook.io/doc/helpers#comparing-large-numbers
  @useResult
  int compare(Uint8List b1, Uint8List b2);

  /// Provides sodium_is_zero.
  ///
  /// Returns whether all bytes of [n] are zero. The check runs in constant
  /// time.
  ///
  /// See https://libsodium.gitbook.io/doc/helpers#testing-for-all-zeros
  @useResult
  bool isZero(Uint8List n);

  /// Provides sodium_increment.
  ///
  /// Interprets [n] as a little-endian encoded, unsigned number, increments it
  /// by 1 and returns the result as a new buffer. The operation runs in
  /// constant time and wraps around on overflow. [n] itself is **not**
  /// modified.
  ///
  /// See https://libsodium.gitbook.io/doc/helpers#incrementing-large-numbers
  @useResult
  Uint8List increment(Uint8List n);

  /// Provides sodium_add.
  ///
  /// Interprets [a] and [b] as little-endian encoded, unsigned numbers and
  /// returns `(a + b) mod 2^(8 * a.length)` as a new buffer. The operation runs
  /// in constant time. Both buffers must have the same length and neither [a]
  /// nor [b] are modified.
  ///
  /// See https://libsodium.gitbook.io/doc/helpers#adding-large-numbers
  @useResult
  Uint8List add(Uint8List a, Uint8List b);

  /// Provides sodium_sub.
  ///
  /// Interprets [a] and [b] as little-endian encoded, unsigned numbers and
  /// returns `(a - b) mod 2^(8 * a.length)` as a new buffer. The operation runs
  /// in constant time. Both buffers must have the same length and neither [a]
  /// nor [b] are modified.
  ///
  /// See https://libsodium.gitbook.io/doc/helpers#subtracting-large-numbers
  @useResult
  Uint8List sub(Uint8List a, Uint8List b);

  /// Provides sodium_bin2hex.
  ///
  /// Converts [bin] into a hexadecimal string with lowercase characters. The
  /// conversion runs in constant time.
  ///
  /// See https://libsodium.gitbook.io/doc/helpers#hexadecimal-encoding-decoding
  @useResult
  String bin2hex(Uint8List bin);

  /// Provides sodium_hex2bin.
  ///
  /// Parses the hexadecimal string [hex] and returns the decoded bytes. Both
  /// lowercase and uppercase characters are accepted, but [hex] must consist of
  /// an even number of hexadecimal characters and nothing else - otherwise a
  /// [SodiumException] is thrown.
  ///
  /// See https://libsodium.gitbook.io/doc/helpers#hexadecimal-encoding-decoding
  @useResult
  Uint8List hex2bin(String hex);

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

  /// Creates an [IpAddress] from the platform native [address].
  ///
  /// On platforms where `dart:io` is available, [address] must be an instance
  /// of [InternetAddress]. On other platforms (e.g. web), [address] must be a
  /// string instead and is identical to calling [ipFromString].
  /// Uses `sodium_ip2bin` internally.
  @useResult
  IpAddress ipFromAddress(ia.InternetAddress address);

  /// Creates an [IpAddress] from the string representation [address].
  ///
  /// [address] must be a valid IPv4 (e.g. `"192.0.2.1"`) or IPv6
  /// (e.g. `"::1"`) address string. Uses `sodium_ip2bin` internally.
  @useResult
  IpAddress ipFromString(String address);

  /// Creates an [IpAddress] from the 16-byte binary representation [bytes].
  ///
  /// [bytes] must be exactly 16 bytes in network byte order, with IPv4
  /// addresses in IPv4-mapped IPv6 form.
  @useResult
  IpAddress ipFromBytes(Uint8List bytes);

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

@internal
mixin SodiumValidations implements Sodium {
  void validateSameLength(Uint8List a, Uint8List b, String name) =>
      Validations.checkIsSame(b.length, a.length, name);

  void validateHex(String hex) => Validations.checkIsAscii(hex, 'hex');
}
