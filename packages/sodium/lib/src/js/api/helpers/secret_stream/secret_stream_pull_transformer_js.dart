import 'dart:js_interop';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../../../api/helpers/secret_stream/pull/secret_stream_pull_transformer.dart';
import '../../../../api/secret_stream.dart';
import '../../../../api/secure_key.dart';
import '../../../../api/sodium_exception.dart';
import '../../../bindings/js_error.dart';
import '../../../bindings/sodium.js.dart';
import '../../../bindings/to_safe_int.dart';
import 'secret_stream_message_tag_jsx.dart';

/// @nodoc
@internal
class SecretStreamPullTransformerSinkJS extends SecretStreamPullTransformerSink<
    SecretstreamXchacha20poly1305State> {
  /// @nodoc
  final LibSodiumJS sodium;

  /// @nodoc
  SecretStreamPullTransformerSinkJS(
    this.sodium,
    // ignore: avoid_positional_boolean_parameters
    bool requireFinalized,
  ) : super(requireFinalized);

  @override
  int get headerBytes =>
      sodium.crypto_secretstream_xchacha20poly1305_HEADERBYTES.toSafeUInt32();

  @override
  SecretstreamXchacha20poly1305State initialize(
    SecureKey key,
    Uint8List header,
  ) =>
      jsErrorWrap(
        () => key.runUnlockedSync(
          (keyData) => sodium.crypto_secretstream_xchacha20poly1305_init_pull(
            header.toJS,
            keyData.toJS,
          ),
        ),
      );

  @override
  void rekey(SecretstreamXchacha20poly1305State cryptoState) => jsErrorWrap(
        // ignore result, as it is always true
        () => sodium.crypto_secretstream_xchacha20poly1305_rekey(cryptoState),
      );

  @override
  SecretStreamPlainMessage decryptMessage(
    SecretstreamXchacha20poly1305State cryptoState,
    SecretStreamCipherMessage event,
  ) {
    final dynamic pullResult = jsErrorWrap<dynamic>(
      () => sodium.crypto_secretstream_xchacha20poly1305_pull(
        cryptoState,
        event.message.toJS,
        event.additionalData?.toJS,
      ),
    );

    if (pullResult is bool) {
      assert(!pullResult, 'unexpected boolean value for SecretStreamPull');
      throw SodiumException();
    } else if (pullResult is SecretStreamPull) {
      return SecretStreamPlainMessage(
        pullResult.message.toDart,
        additionalData: event.additionalData,
        tag: SecretStreamMessageTagJSX.fromValue(
          sodium,
          pullResult.tag.toDartInt.toSafeUInt32(),
        ),
      );
    } else {
      throw TypeError();
    }
  }

  @override
  void disposeState(SecretstreamXchacha20poly1305State cryptoState) {}
}

/// @nodoc
@internal
class SecretStreamPullTransformerJS
    extends SecretStreamPullTransformer<SecretstreamXchacha20poly1305State> {
  /// @nodoc
  final LibSodiumJS sodium;

  /// @nodoc
  const SecretStreamPullTransformerJS(
    this.sodium,
    SecureKey key,
    // ignore: avoid_positional_boolean_parameters
    bool requireFinalized,
  ) : super(key, requireFinalized);

  @override
  SecretStreamPullTransformerSink<SecretstreamXchacha20poly1305State>
      createSink(bool requireFinalized) =>
          SecretStreamPullTransformerSinkJS(sodium, requireFinalized);
}
