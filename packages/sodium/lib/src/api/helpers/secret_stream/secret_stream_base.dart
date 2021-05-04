import 'dart:async';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../secret_stream.dart';
import '../../secure_key.dart';

@internal
mixin SecretStreamBase implements SecretStream {
  @override
  StreamTransformer<Uint8List, Uint8List> createPush(SecureKey key) {
    final transformer = createPushEx(key);
    return StreamTransformer.fromBind(
      (stream) => stream
          .where((message) => message.isNotEmpty)
          .map((message) => SecretStreamPlainMessage(message))
          .transform(transformer)
          .map((event) => event.message),
    );
  }

  @override
  StreamTransformer<Uint8List, Uint8List> createPull(
    SecureKey key, {
    bool requireFinalized = true,
  }) {
    final transformer = createPullEx(key, requireFinalized: requireFinalized);
    return StreamTransformer.fromBind(
      (stream) => stream
          .map((message) => SecretStreamCipherMessage(message))
          .transform(transformer)
          .where((event) => event.message.isNotEmpty)
          .map((event) => event.message),
    );
  }

  @override
  Stream<Uint8List> push({
    required Stream<Uint8List> messageStream,
    required SecureKey key,
  }) =>
      createPush(key).bind(messageStream);

  @override
  Stream<Uint8List> pull({
    required Stream<Uint8List> cipherStream,
    required SecureKey key,
  }) =>
      createPull(key).bind(cipherStream);

  @override
  SecretExStream<SecretStreamCipherMessage> pushEx({
    required Stream<SecretStreamPlainMessage> messageStream,
    required SecureKey key,
  }) =>
      createPushEx(key).bind(messageStream);

  @override
  SecretExStream<SecretStreamPlainMessage> pullEx({
    required Stream<SecretStreamCipherMessage> cipherStream,
    required SecureKey key,
  }) =>
      createPullEx(key).bind(cipherStream);
}
