import 'dart:async';

import 'package:meta/meta.dart';

import '../../secret_stream.dart';
import '../../secure_key.dart';
import 'chunked_stream_transformer.dart';

/// @nodoc
@internal
mixin SecretStreamBase implements SecretStream {
  @override
  StreamTransformer<List<int>, List<int>> createPushChunked({
    required SecureKey key,
    required int chunkSize,
  }) {
    final transformer = createPushEx(key);
    return StreamTransformer.fromBind(
      (stream) => stream
          .transform(ChunkedStreamTransformer(chunkSize))
          .map(
            (chunk) => SecretStreamPlainMessage(
              chunk,
              tag: chunk.length < chunkSize
                  ? SecretStreamMessageTag.finalPush
                  : SecretStreamMessageTag.message,
            ),
          )
          .transform(transformer)
          .map<List<int>>((event) => event.message),
    );
  }

  @override
  StreamTransformer<List<int>, List<int>> createPullChunked({
    required SecureKey key,
    required int chunkSize,
    bool requireFinalized = true,
  }) {
    final transformer = createPullEx(key, requireFinalized: requireFinalized);
    return StreamTransformer.fromBind(
      (stream) => stream
          .transform(
            ChunkedStreamTransformer(
              chunkSize + aBytes,
              headerSize: headerBytes,
            ),
          )
          .map(SecretStreamCipherMessage.new)
          .transform(transformer)
          .map<List<int>>((event) => event.message),
    );
  }

  @override
  Stream<List<int>> pushChunked({
    required Stream<List<int>> messageStream,
    required SecureKey key,
    required int chunkSize,
  }) => createPushChunked(key: key, chunkSize: chunkSize).bind(messageStream);

  @override
  Stream<List<int>> pullChunked({
    required Stream<List<int>> cipherStream,
    required SecureKey key,
    required int chunkSize,
  }) => createPullChunked(key: key, chunkSize: chunkSize).bind(cipherStream);

  @override
  SecretExStream<SecretStreamCipherMessage> pushEx({
    required Stream<SecretStreamPlainMessage> messageStream,
    required SecureKey key,
  }) => createPushEx(key).bind(messageStream);

  @override
  SecretExStream<SecretStreamPlainMessage> pullEx({
    required Stream<SecretStreamCipherMessage> cipherStream,
    required SecureKey key,
  }) => createPullEx(key).bind(cipherStream);
}
