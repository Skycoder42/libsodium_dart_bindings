import 'dart:async';
import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

import 'helpers/validations.dart';
import 'secure_key.dart';

part 'secret_stream.freezed.dart';

enum SecretStreamMessageTag {
  message,
  push,
  finalPush,
  rekey,
}

class StreamClosedEarlyException implements Exception {
  StreamClosedEarlyException();

  // coverage:ignore-start
  @override
  String toString() =>
      'cipher stream was closed before the final push message was received';
  // coverage:ignore-end
}

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

@freezed
class SecretStreamPlainMessage with _$SecretStreamPlainMessage {
  const factory SecretStreamPlainMessage(
    Uint8List message, {
    Uint8List? additionalData,
    @Default(SecretStreamMessageTag.message) SecretStreamMessageTag tag,
  }) = _SecretStreamPlainMessage;
}

@freezed
class SecretStreamCipherMessage with _$SecretStreamCipherMessage {
  const factory SecretStreamCipherMessage(
    Uint8List message, {
    Uint8List? additionalData,
  }) = _SecretStreamCipherMessage;
}

abstract class SecretExStream<T> extends Stream<T> {
  void rekey();
}

abstract class SecretExStreamTransformer<TIn, TOut>
    implements StreamTransformer<TIn, TOut> {
  const SecretExStreamTransformer._(); // coverage:ignore-line

  @override
  SecretExStream<TOut> bind(Stream<TIn> stream);
}

abstract class SecretStream {
  const SecretStream._(); // coverage:ignore-line

  int get aBytes;
  int get headerBytes;
  int get keyBytes;

  SecureKey keygen();

  Stream<Uint8List> push({
    required Stream<Uint8List> messageStream,
    required SecureKey key,
  });

  Stream<Uint8List> pull({
    required Stream<Uint8List> cipherStream,
    required SecureKey key,
  });

  StreamTransformer<Uint8List, Uint8List> createPush(SecureKey key);

  StreamTransformer<Uint8List, Uint8List> createPull(
    SecureKey key, {
    bool requireFinalized = true,
  });

  SecretExStream<SecretStreamCipherMessage> pushEx({
    required Stream<SecretStreamPlainMessage> messageStream,
    required SecureKey key,
  });

  SecretExStream<SecretStreamPlainMessage> pullEx({
    required Stream<SecretStreamCipherMessage> cipherStream,
    required SecureKey key,
  });

  SecretExStreamTransformer<SecretStreamPlainMessage, SecretStreamCipherMessage>
      createPushEx(SecureKey key);

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
