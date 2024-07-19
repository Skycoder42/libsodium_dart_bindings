import 'package:meta/meta.dart';

import '../../../../api/secret_stream.dart';
import '../../../bindings/sodium.js.dart';

/// @nodoc
@internal
extension SecretStreamMessageTagJSX on SecretStreamMessageTag {
  /// @nodoc
  int getValue(LibSodiumJS sodium) {
    switch (this) {
      case SecretStreamMessageTag.message:
        return sodium.crypto_secretstream_xchacha20poly1305_TAG_MESSAGE;
      case SecretStreamMessageTag.push:
        return sodium.crypto_secretstream_xchacha20poly1305_TAG_PUSH;
      case SecretStreamMessageTag.finalPush:
        return sodium.crypto_secretstream_xchacha20poly1305_TAG_FINAL;
      case SecretStreamMessageTag.rekey:
        return sodium.crypto_secretstream_xchacha20poly1305_TAG_REKEY;
    }
  }

  /// @nodoc
  static SecretStreamMessageTag fromValue(LibSodiumJS sodium, int value) {
    if (value == sodium.crypto_secretstream_xchacha20poly1305_TAG_MESSAGE) {
      return SecretStreamMessageTag.message;
    }
    if (value == sodium.crypto_secretstream_xchacha20poly1305_TAG_PUSH) {
      return SecretStreamMessageTag.push;
    }
    if (value == sodium.crypto_secretstream_xchacha20poly1305_TAG_FINAL) {
      return SecretStreamMessageTag.finalPush;
    }
    if (value == sodium.crypto_secretstream_xchacha20poly1305_TAG_REKEY) {
      return SecretStreamMessageTag.rekey;
    }

    throw ArgumentError.value(
      value,
      'value',
      'is not a valid SecretStreamMessageTag',
    );
  }
}
