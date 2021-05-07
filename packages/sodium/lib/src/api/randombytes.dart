import 'dart:typed_data';

/// A meta class that provides access to all libsodium randombytes APIs.
///
/// This class provides the dart interface for the crypto operations documented
/// in https://libsodium.gitbook.io/doc/generating_random_data.
/// Please refer to that documentation for more details about these APIs.
abstract class Randombytes {
  const Randombytes._(); // coverage:ignore-line

  /// Provides randombytes_SEEDBYTES.
  ///
  /// See https://libsodium.gitbook.io/doc/generating_random_data#usage
  int get seedBytes;

  /// Provides randombytes_random.
  ///
  /// See https://libsodium.gitbook.io/doc/generating_random_data#usage
  int random();

  /// Provides randombytes_uniform.
  ///
  /// See https://libsodium.gitbook.io/doc/generating_random_data#usage
  int uniform(int upperBound);

  /// Provides randombytes_buf.
  ///
  /// See https://libsodium.gitbook.io/doc/generating_random_data#usage
  Uint8List buf(int length);

  /// Provides randombytes_buf_deterministic.
  ///
  /// See https://libsodium.gitbook.io/doc/generating_random_data#usage
  Uint8List bufDeterministic(int length, Uint8List seed);

  /// Provides randombytes_close.
  ///
  /// See https://libsodium.gitbook.io/doc/generating_random_data#usage
  void close();

  /// Provides randombytes_stir.
  ///
  /// See https://libsodium.gitbook.io/doc/generating_random_data#usage
  void stir();
}
