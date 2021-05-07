import 'dart:async';
import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

import 'helpers/validations.dart';
import 'secure_key.dart';

part 'secret_stream.freezed.dart';

/// Enum type for the different tags that can be passed to sent messages.
///
/// See https://libsodium.gitbook.io/doc/secret-key_cryptography/secretstream#constants
enum SecretStreamMessageTag {
  /// Provides crypto_secretstream_xchacha20poly1305_TAG_MESSAGE.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/secretstream#constants
  message,

  /// Provides crypto_secretstream_xchacha20poly1305_TAG_PUSH.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/secretstream#constants
  push,

  /// Provides crypto_secretstream_xchacha20poly1305_TAG_FINAL.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/secretstream#constants
  finalPush,

  /// Provides crypto_secretstream_xchacha20poly1305_TAG_REKEY.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/secretstream#constants
  rekey,
}

/// Exception that gets thrown if a decryption stream gets closed too early.
///
/// If a decryption (pull) stream gets closed before the message with the
/// [SecretStreamMessageTag.finalPush] has been decrypted, this exception gets
/// thrown, unless `requireFinalized` has been set to false when the stream
/// was created.
class StreamClosedEarlyException implements Exception {
  StreamClosedEarlyException();

  // coverage:ignore-start
  @override
  String toString() =>
      'cipher stream was closed before the final push message was received';
  // coverage:ignore-end
}

/// Exception that gets thrown if a decryption stream receives an invalid
/// header.
///
/// If the first message that is decrypted by a decryption (pull) stream does
/// not have the correct amout of bytes, this exception will be thrown.
class InvalidHeaderException implements Exception {
  final int expectedBytes;
  final int actualBytes;

  InvalidHeaderException(this.expectedBytes, this.actualBytes);

  // coverage:ignore-start
  @override
  String toString() =>
      'Expected secretstream header with $expectedBytes bytes, '
      'but received $actualBytes bytes';
  // coverage:ignore-end
}

/// A container class for a extended plain message before encryption.
@freezed
class SecretStreamPlainMessage with _$SecretStreamPlainMessage {
  const factory SecretStreamPlainMessage(
    /// The message that should be encrypted.
    Uint8List message, {

    /// Additional data, that should be used to generate authentication data.
    ///
    /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/secretstream#encryption
    Uint8List? additionalData,

    /// The message tag that should be attached to the encrypted message.
    ///
    /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/secretstream#encryption
    /// and https://libsodium.gitbook.io/doc/secret-key_cryptography/secretstream#constants
    @Default(SecretStreamMessageTag.message) SecretStreamMessageTag tag,
  }) = _SecretStreamPlainMessage;
}

/// A container class for a extended cipher message before decryption.
@freezed
class SecretStreamCipherMessage with _$SecretStreamCipherMessage {
  const factory SecretStreamCipherMessage(
    /// The message that should be decrypted.
    Uint8List message, {

    /// Additional data, that should be used to generate authentication data.
    ///
    /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/secretstream#decryption
    Uint8List? additionalData,
  }) = _SecretStreamCipherMessage;
}

/// Extended secret [Stream] that provides a way to rekey the stream.
///
/// You can trigger an explicit rekey of a pull/push stream with this stream.
/// Use [rekey] to do so.
abstract class SecretExStream<T> extends Stream<T> {
  /// Triggers a rekey of the underlying stream en/decryption.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/secretstream#rekeying
  void rekey();
}

/// Extended secret [StreamTransformer] that provides a way to rekey the stream.
///
/// When binding to this transformer, a [SecretExStream] gets created, which can
/// be used to rekey the push/pull stream
///
/// See [SecretExStream]
abstract class SecretExStreamTransformer<TIn, TOut>
    implements StreamTransformer<TIn, TOut> {
  const SecretExStreamTransformer._(); // coverage:ignore-line

  @override
  SecretExStream<TOut> bind(Stream<TIn> stream);
}

/// A meta class that provides access to all libsodium secretstream APIs.
///
/// This class provides the dart interface for the crypto operations documented
/// in https://libsodium.gitbook.io/doc/secret-key_cryptography/secretstream.
/// Please refer to that documentation for more details about these APIs.
abstract class SecretStream {
  const SecretStream._(); // coverage:ignore-line

  /// Provides crypto_secretstream_xchacha20poly1305_ABYTES.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/secretstream#constants
  int get aBytes;

  /// Provides crypto_secretstream_xchacha20poly1305_HEADERBYTES.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/secretstream#constants
  int get headerBytes;

  /// Provides crypto_secretstream_xchacha20poly1305_KEYBYTES.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/secretstream#constants
  int get keyBytes;

  /// Provides crypto_secretstream_xchacha20poly1305_keygen.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/secretstream#encryption
  SecureKey keygen();

  /// Provides crypto_secretstream_xchacha20poly1305_(init_)push.
  ///
  /// Transforms the [messageStream] of plaintext messages to an encrypted
  /// stream using crypto_secretstream_xchacha20poly1305_push with the given
  /// [key]. This is simply a shortcut for [pushEx] in case you only have plain
  /// messages and don't care about additional data or tags.
  ///
  /// See [pushEx] for more details on then encryption process.
  Stream<Uint8List> push({
    required Stream<Uint8List> messageStream,
    required SecureKey key,
  });

  /// Provides crypto_secretstream_xchacha20poly1305_(init_)pull.
  ///
  /// Transforms the [cipherStream] of encrypted messages to a decrypted plain
  /// stream using crypto_secretstream_xchacha20poly1305_pull with the given
  /// [key]. This is simply a shortcut for [pullEx] in case you only have cipher
  /// messages and don't care about additional data or tags.
  ///
  /// See [pullEx] for more details on then decryption process.
  Stream<Uint8List> pull({
    required Stream<Uint8List> cipherStream,
    required SecureKey key,
  });

  /// Provides crypto_secretstream_xchacha20poly1305_(init_)push.
  ///
  /// Works just like [push], but instead of creating a stream, it creates a
  /// [StreamTransformer] with [key], which can then be used to create push
  /// encryption streams from it.
  ///
  /// See [createPushEx] for more details on then encryption process.
  StreamTransformer<Uint8List, Uint8List> createPush(SecureKey key);

  /// Provides crypto_secretstream_xchacha20poly1305_(init_)pull.
  ///
  /// Works just like [pull], but instead of creating a stream, it creates a
  /// [StreamTransformer] with [key], which can then be used to create pull
  /// decryption streams from it. In addition, you can specify
  /// [requireFinalized] to control if the stream needs to receive the
  /// [SecretStreamMessageTag.finalPush] to be closed gracefully. If enabled
  /// (the default) and the last message does not have this tag, an error will
  /// be added to the stream before it is closed.
  ///
  /// See [createPullEx] for more details on then decryption process.
  StreamTransformer<Uint8List, Uint8List> createPull(
    SecureKey key, {
    bool requireFinalized = true,
  });

  /// Provides crypto_secretstream_xchacha20poly1305_(init_)push.
  ///
  /// Transforms the [messageStream] of plaintext messages to an encrypted
  /// stream using crypto_secretstream_xchacha20poly1305_push with the given
  /// [key].
  ///
  /// Unlike the C API, which requires manual state management etc., this API
  /// combines all the required parts into a single, simple dart stream. As a
  /// first step, crypto_secretstream_xchacha20poly1305_init_push is used to
  /// generate the stream state from the [key] and the created header is sent
  /// as the first message of the returned [SecretExStream]. After that, any
  /// plain message (optionally with additional data and a tag) that is passed
  /// in via [messageStream] is encrypted with
  /// crypto_secretstream_xchacha20poly1305_push.
  ///
  /// The stream also handles it's internal state gracefully and can react
  /// to tags and problems with the encryption, if the occur. It is also
  /// possible to explicitly rekey the stream via [SecretExStream.rekey].
  ///
  /// **Note:** If you want to gracefully end a push stream, the last message
  /// needs to have the [SecretStreamMessageTag.finalPush] tag. After that, you
  /// must not send any other messages and close the [messageStream]. If you
  /// close the stream without the tag, an empty message is automatically
  /// created and sent before the returned stream gets closed.
  ///
  /// This method is basically a shortcut for [createPushEx].bind(). Check the
  /// documentation of [createPushEx] if you need a transformer instead of a
  /// stream.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/secretstream#encryption
  SecretExStream<SecretStreamCipherMessage> pushEx({
    required Stream<SecretStreamPlainMessage> messageStream,
    required SecureKey key,
  });

  /// Provides crypto_secretstream_xchacha20poly1305_(init_)pull.
  ///
  /// Transforms the [cipherStream] of encrypted messages to a decrypted plain
  /// stream using crypto_secretstream_xchacha20poly1305_pull with the given
  /// [key].
  ///
  /// Unlike the C API, which requires manual state management etc., this API
  /// combines all the required parts into a single, simple dart stream. As a
  /// first step, crypto_secretstream_xchacha20poly1305_init_pull is used to
  /// generate the stream state from the [key] and the header, which is expected
  /// to be the first message that is added into [cipherStream]. After that, any
  /// cipher message (optionally with additional data) that is passed in the
  /// stream is encrypted with crypto_secretstream_xchacha20poly1305_push and
  /// the result returned as [SecretExStream].
  ///
  /// The stream also handles it's internal state gracefully and can react
  /// to tags and problems with the encryption, if the occur. It is also
  /// possible to explicitly rekey the stream via [SecretExStream.rekey].
  ///
  /// **Note:** It is required that the first message in the [cipherStream] is
  /// the header. If you created the stream with [pushEx], this will aready be
  /// the case. When getting the stream from other sources, make sure to always
  /// pass in the header first. Also, if the last message of [cipherStream] does
  /// not have the [SecretStreamMessageTag.finalPush] tag, an error will be
  /// added to the returned stream before it gets closed. To change this
  /// behaviour, use [createPullEx] instead.
  ///
  /// This method is basically a shortcut for [createPullEx].bind(). Check the
  /// documentation of [createPullEx] if you need a transformer instead of a
  /// stream or need to adjust the finalization handling.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/secretstream#decryption
  SecretExStream<SecretStreamPlainMessage> pullEx({
    required Stream<SecretStreamCipherMessage> cipherStream,
    required SecureKey key,
  });

  /// Provides crypto_secretstream_xchacha20poly1305_(init_)push.
  ///
  /// Works just like [pushEx], but instead of creating a stream, it creates a
  /// [SecretExStreamTransformer] with [key], which can then be used to create
  /// push encryption streams from it.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/secretstream#encryption
  SecretExStreamTransformer<SecretStreamPlainMessage, SecretStreamCipherMessage>
      createPushEx(SecureKey key);

  /// Provides crypto_secretstream_xchacha20poly1305_(init_)pull.
  ///
  /// Works just like [pullEx], but instead of creating a stream, it creates a
  /// [SecretExStreamTransformer] with [key], which can then be used to create
  /// pull decryption streams from it. In addition, you can specify
  /// [requireFinalized] to control if the stream needs to receive the
  /// [SecretStreamMessageTag.finalPush] to be closed gracefully. If enabled
  /// (the default) and the last message does not have this tag, an error will
  /// be added to the stream before it is closed.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/secretstream#decryption
  SecretExStreamTransformer<SecretStreamCipherMessage, SecretStreamPlainMessage>
      createPullEx(
    SecureKey key, {
    bool requireFinalized = true,
  });
}

@internal
mixin SecretStreamValidations implements SecretStream {
  void validateKey(SecureKey key) => Validations.checkIsSame(
        key.length,
        keyBytes,
        'key',
      );
}
