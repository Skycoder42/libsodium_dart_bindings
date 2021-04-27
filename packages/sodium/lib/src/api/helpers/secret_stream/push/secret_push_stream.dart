import 'dart:async';

import 'package:meta/meta.dart';

import '../../../secret_stream.dart';
import 'secret_stream_push_transformer.dart';

@internal
class SecretPushStream extends SecretExStream<SecretStreamCipherMessage> {
  final SecretStreamPushTransformerSink sink;
  final Stream<SecretStreamCipherMessage> stream;

  SecretPushStream(this.sink, this.stream);

  @override
  StreamSubscription<SecretStreamCipherMessage> listen(
    void Function(SecretStreamCipherMessage event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) =>
      stream.listen(
        onData,
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError,
      );

  @override
  void rekey() => sink.triggerRekey();
}
