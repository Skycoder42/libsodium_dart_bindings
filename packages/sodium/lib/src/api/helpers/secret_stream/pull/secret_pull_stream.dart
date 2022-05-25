import 'dart:async';

import 'package:meta/meta.dart';

import '../../../secret_stream.dart';
import 'secret_stream_pull_transformer.dart';

/// @nodoc
@internal
class SecretPullStream extends SecretExStream<SecretStreamPlainMessage> {
  /// @nodoc
  final SecretStreamPullTransformerSink sink;

  /// @nodoc
  final Stream<SecretStreamPlainMessage> stream;

  /// @nodoc
  SecretPullStream(this.sink, this.stream);

  @override
  StreamSubscription<SecretStreamPlainMessage> listen(
    void Function(SecretStreamPlainMessage event)? onData, {
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
