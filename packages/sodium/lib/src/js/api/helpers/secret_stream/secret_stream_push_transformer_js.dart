import 'dart:js_interop';

import 'package:meta/meta.dart';

import '../../../../api/helpers/secret_stream/push/init_push_result.dart';
import '../../../../api/helpers/secret_stream/push/secret_stream_push_transformer.dart';
import '../../../../api/secret_stream.dart';
import '../../../../api/secure_key.dart';
import '../../../bindings/js_error.dart';
import '../../../bindings/sodium.js.dart';
import 'secret_stream_message_tag_jsx.dart';

/// @nodoc
@internal
class SecretStreamPushTransformerSinkJS
    extends
        SecretStreamPushTransformerSink<SecretstreamXchacha20poly1305State> {
  /// @nodoc
  final LibSodiumJS sodium;

  /// @nodoc
  SecretStreamPushTransformerSinkJS(this.sodium);

  @override
  InitPushResult<SecretstreamXchacha20poly1305State> initialize(SecureKey key) {
    final initResult = jsErrorWrap(
      () => key.runUnlockedSync(
        (keyData) => sodium.crypto_secretstream_xchacha20poly1305_init_push(
          keyData.toJS,
        ),
      ),
    );

    return InitPushResult(
      header: initResult.header.toDart,
      state: initResult.state,
    );
  }

  @override
  void rekey(SecretstreamXchacha20poly1305State cryptoState) => jsErrorWrap(
    // always returns true, ignore result
    () => sodium.crypto_secretstream_xchacha20poly1305_rekey(cryptoState),
  );

  @override
  SecretStreamCipherMessage encryptMessage(
    SecretstreamXchacha20poly1305State cryptoState,
    SecretStreamPlainMessage event,
  ) {
    final cipherText = jsErrorWrap(
      () => sodium.crypto_secretstream_xchacha20poly1305_push(
        cryptoState,
        event.message.toJS,
        event.additionalData?.toJS,
        event.tag.getValue(sodium),
      ),
    );

    return SecretStreamCipherMessage(
      cipherText.toDart,
      additionalData: event.additionalData,
    );
  }

  @override
  void disposeState(SecretstreamXchacha20poly1305State cryptoState) {}
}

/// @nodoc
@internal
class SecretStreamPushTransformerJS
    extends SecretStreamPushTransformer<SecretstreamXchacha20poly1305State> {
  /// @nodoc
  final LibSodiumJS sodium;

  /// @nodoc
  const SecretStreamPushTransformerJS(this.sodium, SecureKey key) : super(key);

  @override
  SecretStreamPushTransformerSink<SecretstreamXchacha20poly1305State>
  createSink() => SecretStreamPushTransformerSinkJS(sodium);
}
