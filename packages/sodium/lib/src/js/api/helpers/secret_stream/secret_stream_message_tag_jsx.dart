import 'package:meta/meta.dart';

import '../../../../api/secret_stream.dart';
import '../../../bindings/sodium.js.dart';
import '../../../bindings/to_safe_int.dart';

/// @nodoc
@internal
extension SecretStreamMessageTagJSX on SecretStreamMessageTag {
  /// @nodoc
  int getValue(LibSodiumJS sodium) {
    switch (this) {
      case SecretStreamMessageTag.message:
        return sodium.crypto_secretstream_xchacha20poly1305_TAG_MESSAGE
            .toSafeUInt32();
      case SecretStreamMessageTag.push:
        return sodium.crypto_secretstream_xchacha20poly1305_TAG_PUSH
            .toSafeUInt32();
      case SecretStreamMessageTag.finalPush:
        return sodium.crypto_secretstream_xchacha20poly1305_TAG_FINAL
            .toSafeUInt32();
      case SecretStreamMessageTag.rekey:
        return sodium.crypto_secretstream_xchacha20poly1305_TAG_REKEY
            .toSafeUInt32();
    }
  }

  /// @nodoc
  static SecretStreamMessageTag fromValue(LibSodiumJS sodium, int value) {
    if (value ==
        sodium.crypto_secretstream_xchacha20poly1305_TAG_MESSAGE
            .toSafeUInt32()) {
      return SecretStreamMessageTag.message;
    }
    if (value ==
        sodium.crypto_secretstream_xchacha20poly1305_TAG_PUSH.toSafeUInt32()) {
      return SecretStreamMessageTag.push;
    }
    if (value ==
        sodium.crypto_secretstream_xchacha20poly1305_TAG_FINAL.toSafeUInt32()) {
      return SecretStreamMessageTag.finalPush;
    }
    if (value ==
        sodium.crypto_secretstream_xchacha20poly1305_TAG_REKEY.toSafeUInt32()) {
      return SecretStreamMessageTag.rekey;
    }

    throw ArgumentError.value(
      value,
      'value',
      'is not a valid SecretStreamMessageTag',
    );
  }
}
