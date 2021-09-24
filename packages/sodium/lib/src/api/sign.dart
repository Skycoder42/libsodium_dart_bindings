import 'dart:async';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import 'helpers/validations.dart';
import 'key_pair.dart';
import 'secure_key.dart';

/// A typed [StreamConsumer], which is used to generate a signature from a
/// stream of data.
///
/// See [Sign.createConsumer] for more details.
abstract class SignatureConsumer implements StreamConsumer<Uint8List> {
  const SignatureConsumer._(); // coverage:ignore-line

  /// A future that resolves to the signature of the data.
  ///
  /// This is the same future as returned by [close]. It will be resolved as
  /// soon as the consumer is closed and will either produce the actual
  /// signature of the consumed data, or an error if something went wrong.
  Future<Uint8List> get signature;

  /// Closes the consumer and calculates the signature.
  ///
  /// This internally finalizes the consumer and calculates the signature over
  /// all the received data. Once done, the signature is returned, or an error
  /// thrown, if it failed. The returned future is the same as the on provided
  /// via [signature].
  ///
  /// After having been closed, no more streams can be added to the consumer.
  /// See [StreamConsumer.close] for more details.
  @override
  Future<Uint8List> close();
}

/// A typed [StreamConsumer], which is used to verify a signature from a stream
/// of data.
///
/// See [Sign.createVerifyConsumer] for more details.
abstract class VerificationConsumer implements StreamConsumer<Uint8List> {
  const VerificationConsumer._(); // coverage:ignore-line

  /// A future that resolves to the signature validation of the data.
  ///
  /// This is the same future as returned by [close]. It will be resolved as
  /// soon as the consumer is closed and will either report the correctness of
  /// the signature over the consumed data, or an error if something went wrong.
  Future<bool> get signatureValid;

  /// Closes the consumer and verifies the signature.
  ///
  /// This internally finalizes the consumer and verifies the signature over
  /// all the received data. Once done, the validity of the signature is
  /// returned, or an error thrown, if it failed. The returned future is the
  /// same as the on provided via [signatureValid].
  ///
  /// After having been closed, no more streams can be added to the consumer.
  /// See [StreamConsumer.close] for more details.
  @override
  Future<bool> close();
}

/// A meta class that provides access to all libsodium sign APIs.
///
/// This class provides the dart interface for the crypto operations documented
/// in https://libsodium.gitbook.io/doc/public-key_cryptography/public-key_signatures.
/// Please refer to that documentation for more details about these APIs.
abstract class Sign {
  const Sign._(); // coverage:ignore-line

  /// Provides crypto_sign_PUBLICKEYBYTES.
  ///
  /// See https://libsodium.gitbook.io/doc/public-key_cryptography/public-key_signatures#constants
  int get publicKeyBytes;

  /// Provides crypto_sign_SECRETKEYBYTES.
  ///
  /// See https://libsodium.gitbook.io/doc/public-key_cryptography/public-key_signatures#constants
  int get secretKeyBytes;

  /// Provides crypto_sign_BYTES.
  ///
  /// See https://libsodium.gitbook.io/doc/public-key_cryptography/public-key_signatures#constants
  int get bytes;

  /// Provides crypto_sign_SEEDBYTES.
  ///
  /// See https://libsodium.gitbook.io/doc/public-key_cryptography/public-key_signatures#constants
  int get seedBytes;

  /// Provides crypto_sign_keypair.
  ///
  /// See https://libsodium.gitbook.io/doc/public-key_cryptography/public-key_signatures#key-pair-generation
  KeyPair keyPair();

  /// Provides crypto_sign_seed_keypair.
  ///
  /// See https://libsodium.gitbook.io/doc/public-key_cryptography/public-key_signatures#key-pair-generation
  KeyPair seedKeyPair(SecureKey seed);

  /// Provides crypto_sign.
  ///
  /// See https://libsodium.gitbook.io/doc/public-key_cryptography/public-key_signatures#combined-mode
  Uint8List call({
    required Uint8List message,
    required SecureKey secretKey,
  });

  /// Provides crypto_sign_open.
  ///
  /// See https://libsodium.gitbook.io/doc/public-key_cryptography/public-key_signatures#combined-mode
  Uint8List open({
    required Uint8List signedMessage,
    required Uint8List publicKey,
  });

  /// Provides crypto_sign_detached.
  ///
  /// See https://libsodium.gitbook.io/doc/public-key_cryptography/public-key_signatures#detached-mode
  Uint8List detached({
    required Uint8List message,
    required SecureKey secretKey,
  });

  /// Provides crypto_sign_verify_detached.
  ///
  /// See https://libsodium.gitbook.io/doc/public-key_cryptography/public-key_signatures#detached-mode
  bool verifyDetached({
    required Uint8List message,
    required Uint8List signature,
    required Uint8List publicKey,
  });

  /// Creates a [StreamConsumer] for generating a signature from a stream.
  ///
  /// The returned [SignatureConsumer] is basically a typed [StreamConsumer],
  /// that wraps the signature streaming APIs. Creating the consumer will call
  /// crypto_sign_init, adding messages to it via [SignatureConsumer.addStream]
  /// will call crypto_sign_update for every event in the stream. After you are
  /// done adding messages, you can [SignatureConsumer.close] it, which will
  /// call crypto_sign_final_create internally and return the signature of the
  /// data created from [secretKey].
  ///
  /// For simpler usage, if you only have a single input [Stream] and simply
  /// want to get the signature from it, you ca use [stream] instead.
  ///
  /// See https://libsodium.gitbook.io/doc/public-key_cryptography/public-key_signatures#multi-part-messages
  SignatureConsumer createConsumer({
    required SecureKey secretKey,
  });

  /// Creates a [StreamConsumer] for verifying a signature from a stream.
  ///
  /// The returned [VerificationConsumer] is basically a typed [StreamConsumer],
  /// that wraps the signature streaming APIs. Creating the consumer will call
  /// crypto_sign_init, adding messages to it via [SignatureConsumer.addStream]
  /// will call crypto_sign_update for every event in the stream. After you are
  /// done adding messages, you can [SignatureConsumer.close] it, which will
  /// call crypto_sign_final_verify internally and return whether the given
  /// [signature] is correct for the received data, based on [publicKey].
  ///
  /// For simpler usage, if you only have a single input [Stream] and simply
  /// want to check if the signature is valid, you ca use [verifyStream]
  /// instead.
  ///
  /// See https://libsodium.gitbook.io/doc/public-key_cryptography/public-key_signatures#multi-part-messages
  VerificationConsumer createVerifyConsumer({
    required Uint8List signature,
    required Uint8List publicKey,
  });

  /// Get the signature from an aynchronous stream of data.
  ///
  /// This is a shortcut for [createConsumer], which simply calls [Stream.pipe]
  /// on the [messages] stream and pipes it into the consumer. The returned
  /// result is the signature over all the data in the [messages] stream,
  /// created by [secretKey].
  ///
  /// See https://libsodium.gitbook.io/doc/public-key_cryptography/public-key_signatures#multi-part-messages
  Future<Uint8List> stream({
    required Stream<Uint8List> messages,
    required SecureKey secretKey,
  });

  /// Validate the signature from an aynchronous stream of data.
  ///
  /// This is a shortcut for [createVerifyConsumer], which simply calls
  /// [Stream.pipe] on the [messages] stream and pipes it into the consumer. The
  /// returned result is whether the [signature] over all the data in the
  /// [messages] stream is correct, based on [publicKey].
  ///
  /// See https://libsodium.gitbook.io/doc/public-key_cryptography/public-key_signatures#multi-part-messages
  Future<bool> verifyStream({
    required Stream<Uint8List> messages,
    required Uint8List signature,
    required Uint8List publicKey,
  });

  /// Provides crypto_sign_ed25519_sk_to_seed.
  ///
  /// **⚠️ Important:** On the web, this is only available when using the sumo
  /// version of sodium.js
  ///
  /// See https://libsodium.gitbook.io/doc/public-key_cryptography/public-key_signatures#extracting-the-seed-and-the-public-key-from-the-secret-key
  SecureKey skToSeed(SecureKey secretKey);

  /// Provides crypto_sign_ed25519_sk_to_pk.
  ///
  /// **⚠️ Important:** On the web, this is only available when using the sumo
  /// version of sodium.js
  ///
  /// See https://libsodium.gitbook.io/doc/public-key_cryptography/public-key_signatures#extracting-the-seed-and-the-public-key-from-the-secret-key
  Uint8List skToPk(SecureKey secretKey);
}

@internal
mixin SignValidations implements Sign {
  void validatePublicKey(Uint8List publicKey) => Validations.checkIsSame(
        publicKey.length,
        publicKeyBytes,
        'publicKey',
      );

  void validateSecretKey(SecureKey secretKey) => Validations.checkIsSame(
        secretKey.length,
        secretKeyBytes,
        'secretKey',
      );

  void validateSignature(Uint8List signature) => Validations.checkIsSame(
        signature.length,
        bytes,
        'signature',
      );

  void validateSignedMessage(Uint8List signedMessage) =>
      Validations.checkAtLeast(
        signedMessage.length,
        bytes,
        'signature',
      );

  void validateSeed(SecureKey seed) => Validations.checkIsSame(
        seed.length,
        seedBytes,
        'seed',
      );

  @override
  Future<Uint8List> stream({
    required Stream<Uint8List> messages,
    required SecureKey secretKey,
  }) =>
      messages
          .pipe(createConsumer(secretKey: secretKey))
          .then((dynamic value) => value as Uint8List);

  @override
  Future<bool> verifyStream({
    required Stream<Uint8List> messages,
    required Uint8List signature,
    required Uint8List publicKey,
  }) =>
      messages
          .pipe(
            createVerifyConsumer(
              signature: signature,
              publicKey: publicKey,
            ),
          )
          .then((dynamic value) => value as bool);
}
