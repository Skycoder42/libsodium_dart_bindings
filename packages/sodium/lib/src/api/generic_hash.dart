import 'dart:async';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import 'helpers/validations.dart';
import 'secure_key.dart';

/// A typed [StreamConsumer], which is used to generate a hash from a stream of
/// data.
///
/// See [GenericHash.createConsumer] for more details.
abstract class GenericHashConsumer implements StreamConsumer<Uint8List> {
  const GenericHashConsumer._(); // coverage:ignore-line

  /// A future that resolves to the hash of the data.
  ///
  /// This is the same future as returned by [close]. It will be resolved as
  /// soon as the consumer is closed and will either produce the actual
  /// hash of the consumed data, or an error if something went wrong.
  Future<Uint8List> get hash;

  /// Closes the consumer and calculates the hash.
  ///
  /// This internally finalizes the consumer and calculates the hash over all
  /// the received data. Once done, the hash is returned, or an error thrown, if
  /// it failed. The returned future is the same as the on provided via [hash].
  ///
  /// After having been closed, no more streams can be added to the consumer.
  /// See [StreamConsumer.close] for more details.
  @override
  Future<Uint8List> close();
}

/// A meta class that provides access to all libsodium generichash APIs.
///
/// This class provides the dart interface for the crypto operations documented
/// in https://libsodium.gitbook.io/doc/hashing/generic_hashing.
/// Please refer to that documentation for more details about these APIs.
abstract class GenericHash {
  const GenericHash._(); // coverage:ignore-line

  /// Provides crypto_generichash_BYTES.
  ///
  /// See https://libsodium.gitbook.io/doc/hashing/generic_hashing#constants
  int get bytes;

  /// Provides crypto_generichash_BYTES_MIN.
  ///
  /// See https://libsodium.gitbook.io/doc/hashing/generic_hashing#constants
  int get bytesMin;

  /// Provides crypto_generichash_BYTES_MAX.
  ///
  /// See https://libsodium.gitbook.io/doc/hashing/generic_hashing#constants
  int get bytesMax;

  /// Provides crypto_generichash_KEYBYTES.
  ///
  /// See https://libsodium.gitbook.io/doc/hashing/generic_hashing#constants
  int get keyBytes;

  /// Provides crypto_generichash_KEYBYTES_MIN.
  ///
  /// See https://libsodium.gitbook.io/doc/hashing/generic_hashing#constants
  int get keyBytesMin;

  /// Provides crypto_generichash_KEYBYTES_MAX.
  ///
  /// See https://libsodium.gitbook.io/doc/hashing/generic_hashing#constants
  int get keyBytesMax;

  /// Provides crypto_generichash_keygen.
  ///
  /// See https://libsodium.gitbook.io/doc/hashing/generic_hashing#usage
  SecureKey keygen();

  /// Provides crypto_generichash.
  ///
  /// See https://libsodium.gitbook.io/doc/hashing/generic_hashing#usage
  Uint8List call({
    required Uint8List message,
    int? outLen,
    SecureKey? key,
  });

  /// Creates a [StreamConsumer] for generating a hash from a stream.
  ///
  /// The returned [GenericHashConsumer] is basically a typed [StreamConsumer],
  /// that wraps the generichash streaming APIs. Creating the consumer will call
  /// crypto_generichash_init, adding messages to it via
  /// [GenericHashConsumer.addStream] will call crypto_generichash_update for
  /// every event in the stream. After you are done adding messages, you can
  /// [GenericHashConsumer.close] it, which will call crypto_generichash_final
  /// internally and return the hash of the data.
  ///
  /// Optionally, you can pass [outLen] to modify the length of the generated
  /// hash and [key] if you want to use the hash as MAC.
  ///
  /// For simpler usage, if you only have a single input [Stream] and simply
  /// want to get the hash from it, you ca use [stream] instead.
  ///
  /// See https://libsodium.gitbook.io/doc/hashing/generic_hashing#usage
  GenericHashConsumer createConsumer({
    int? outLen,
    SecureKey? key,
  });

  /// Get the hash from an aynchronous stream of data.
  ///
  /// This is a shortcut for [createConsumer], which simply calls [Stream.pipe]
  /// on the [messages] stream and pipes it into the consumer. The returned
  /// result is the hash over all the data in the [messages] stream, optionally
  /// with a modified [outLen] or a [key].
  ///
  /// See https://libsodium.gitbook.io/doc/hashing/generic_hashing#usage
  Future<Uint8List> stream({
    required Stream<Uint8List> messages,
    int? outLen,
    SecureKey? key,
  });
}

/// @nodoc
@internal
mixin GenericHashValidations implements GenericHash {
  /// @nodoc
  void validateOutLen(int outLen) => Validations.checkInRange(
        outLen,
        bytesMin,
        bytesMax,
        'outLen',
      );

  /// @nodoc
  void validateKey(SecureKey key) => Validations.checkInRange(
        key.length,
        keyBytesMin,
        keyBytesMax,
        'key',
      );

  @override
  Future<Uint8List> stream({
    required Stream<Uint8List> messages,
    int? outLen,
    SecureKey? key,
  }) =>
      messages
          .pipe(
            createConsumer(
              outLen: outLen,
              key: key,
            ),
          )
          .then((dynamic value) => value as Uint8List);
}
