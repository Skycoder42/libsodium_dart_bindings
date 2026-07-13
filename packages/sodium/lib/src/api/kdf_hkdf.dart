import 'dart:async';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import 'helpers/validations.dart';
import 'secure_key.dart';

/// A typed [StreamConsumer], which is used to extract a HKDF master key from a
/// stream of input keying material.
///
/// See [KdfHkdf.createExtractConsumer] for more details.
abstract interface class KdfHkdfExtractConsumer
    implements StreamConsumer<Uint8List>, Sink<Uint8List> {
  /// A future that resolves to the extracted master key.
  ///
  /// This is the same future as returned by [close]. It will be resolved as
  /// soon as the consumer is closed and will either produce the actual master
  /// key extracted from the consumed input keying material, or an error if
  /// something went wrong.
  Future<SecureKey> get masterKey;

  /// Closes the consumer and extracts the master key.
  ///
  /// This internally finalizes the consumer and extracts the master key from
  /// all the received input keying material. Once done, the key is returned, or
  /// an error thrown, if it failed. The returned future is the same as the one
  /// provided via [masterKey].
  ///
  /// After having been closed, no more streams can be added to the consumer.
  /// See [StreamConsumer.close] for more details.
  @override
  Future<SecureKey> close();
}

/// A meta class that provides access to all libsodium kdf_hkdf APIs.
///
/// This class provides the dart interface for the crypto operations documented
/// in https://libsodium.gitbook.io/doc/key_derivation/hkdf.
/// Please refer to that documentation for more details about these APIs.
///
/// This interface represents a single HKDF variant (either HKDF-SHA-256 or
/// HKDF-SHA-512). The operations are identical for both variants; only the
/// underlying hash function and the reported constant sizes differ.
abstract interface class KdfHkdf {
  /// Provides crypto_kdf_hkdf_shaXXX_KEYBYTES.
  ///
  /// See https://libsodium.gitbook.io/doc/key_derivation/hkdf#constants
  int get keyBytes;

  /// Provides crypto_kdf_hkdf_shaXXX_BYTES_MIN.
  ///
  /// See https://libsodium.gitbook.io/doc/key_derivation/hkdf#constants
  int get bytesMin;

  /// Provides crypto_kdf_hkdf_shaXXX_BYTES_MAX.
  ///
  /// See https://libsodium.gitbook.io/doc/key_derivation/hkdf#constants
  int get bytesMax;

  /// Provides crypto_kdf_hkdf_shaXXX_keygen.
  ///
  /// Generates a new random master key that is suitable to be used with
  /// [expand].
  ///
  /// See https://libsodium.gitbook.io/doc/key_derivation/hkdf#deriving-keys-from-a-master-key
  SecureKey keygen();

  /// Provides crypto_kdf_hkdf_shaXXX_extract.
  ///
  /// Extracts a master key of [keyBytes] length from the input keying material
  /// [ikm] and an optional [salt].
  ///
  /// See https://libsodium.gitbook.io/doc/key_derivation/hkdf#creating-a-master-key-from-input-keying-material
  SecureKey extract({Uint8List? salt, required Uint8List ikm});

  /// Provides crypto_kdf_hkdf_shaXXX_extract_init, _update and _final.
  ///
  /// Creates a [KdfHkdfExtractConsumer], which is basically a typed
  /// [StreamConsumer], that wraps the incremental HKDF extract APIs. Creating
  /// the consumer will call crypto_kdf_hkdf_shaXXX_extract_init with the given
  /// [salt], adding input keying material to it via
  /// [KdfHkdfExtractConsumer.addStream] will call
  /// crypto_kdf_hkdf_shaXXX_extract_update for every event in the stream. After
  /// you are done adding data, you can [KdfHkdfExtractConsumer.close] it, which
  /// will call crypto_kdf_hkdf_shaXXX_extract_final internally and return the
  /// extracted master key.
  ///
  /// For simpler usage, if you only have a single input [Stream] and simply
  /// want to get the master key from it, you can use [extractStream] instead.
  ///
  /// See https://libsodium.gitbook.io/doc/key_derivation/hkdf#incremental-entropy-extraction
  KdfHkdfExtractConsumer createExtractConsumer({Uint8List? salt});

  /// Extract a master key from an asynchronous stream of input keying material.
  ///
  /// This is a shortcut for [createExtractConsumer], which simply calls
  /// [Stream.pipe] on the [ikm] stream and pipes it into the consumer. The
  /// returned result is the master key extracted from all the data in the [ikm]
  /// stream, using the given [salt].
  ///
  /// See https://libsodium.gitbook.io/doc/key_derivation/hkdf#incremental-entropy-extraction
  Future<SecureKey> extractStream({
    Uint8List? salt,
    required Stream<Uint8List> ikm,
  });

  /// Provides crypto_kdf_hkdf_shaXXX_expand.
  ///
  /// Derives a subkey of [outLen] bytes from the [masterKey] and a [context].
  /// The [outLen] must be between [bytesMin] and [bytesMax].
  ///
  /// See https://libsodium.gitbook.io/doc/key_derivation/hkdf#deriving-keys-from-a-master-key
  SecureKey expand({
    required SecureKey masterKey,
    required String context,
    required int outLen,
  });
}

/// @nodoc
@internal
mixin KdfHkdfValidations implements KdfHkdf {
  /// @nodoc
  void validateMasterKey(SecureKey masterKey) =>
      Validations.checkIsSame(masterKey.length, keyBytes, 'masterKey');

  /// @nodoc
  void validateOutLen(int outLen) =>
      Validations.checkInRange(outLen, bytesMin, bytesMax, 'outLen');

  @override
  Future<SecureKey> extractStream({
    Uint8List? salt,
    required Stream<Uint8List> ikm,
  }) => ikm
      .pipe(createExtractConsumer(salt: salt))
      .then((dynamic value) => value as SecureKey);
}
