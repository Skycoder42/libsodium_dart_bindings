import 'dart:async';

import 'package:meta/meta.dart';

import '../../../secret_stream.dart';
import 'secret_stream_pull_transformer.dart';

@internal
// ignore: public_member_api_docs false positive
class SecretPullStream(
  final SecretStreamPullTransformerSink sink,

  final Stream<SecretStreamPlainMessage> stream,
) extends SecretExStream<SecretStreamPlainMessage> {
  @override
  StreamSubscription<SecretStreamPlainMessage> listen(
    void Function(SecretStreamPlainMessage event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) => stream.listen(
    onData,
    onError: onError,
    onDone: onDone,
    cancelOnError: cancelOnError,
  );

  @override
  void rekey() => sink.triggerRekey();
}
