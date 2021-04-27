import 'package:meta/meta.dart';

import '../../../../api/secret_stream.dart';
import '../../../bindings/libsodium.ffi.dart';

@internal
extension SecretStreamMessageTagX on SecretStreamMessageTag {
  int getValue(LibSodiumFFI sodium) {
    switch (this) {
      case SecretStreamMessageTag.message:
        return sodium.crypto_secretstream_xchacha20poly1305_tag_message();
      case SecretStreamMessageTag.push:
        return sodium.crypto_secretstream_xchacha20poly1305_tag_push();
      case SecretStreamMessageTag.finalPush:
        return sodium.crypto_secretstream_xchacha20poly1305_tag_final();
      case SecretStreamMessageTag.rekey:
        return sodium.crypto_secretstream_xchacha20poly1305_tag_rekey();
    }
  }

  static SecretStreamMessageTag fromValue(LibSodiumFFI sodium, int value) {
    if (value == sodium.crypto_secretstream_xchacha20poly1305_tag_message()) {
      return SecretStreamMessageTag.message;
    }
    if (value == sodium.crypto_secretstream_xchacha20poly1305_tag_push()) {
      return SecretStreamMessageTag.push;
    }
    if (value == sodium.crypto_secretstream_xchacha20poly1305_tag_final()) {
      return SecretStreamMessageTag.finalPush;
    }
    if (value == sodium.crypto_secretstream_xchacha20poly1305_tag_rekey()) {
      return SecretStreamMessageTag.rekey;
    }

    throw ArgumentError.value(
      value,
      'value',
      'is not a valid SecretStreamMessageTag',
    );
  }
}
