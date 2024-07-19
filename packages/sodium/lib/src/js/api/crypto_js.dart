import 'package:meta/meta.dart';

import '../../api/aead.dart';
import '../../api/auth.dart';
import '../../api/box.dart';
import '../../api/crypto.dart';
import '../../api/generic_hash.dart';
import '../../api/kdf.dart';
import '../../api/kx.dart';
import '../../api/secret_box.dart';
import '../../api/secret_stream.dart';
import '../../api/short_hash.dart';
import '../../api/sign.dart';
import '../bindings/sodium.js.dart' hide SecretBox;
import 'aead_chacha20poly1305_js.dart';
import 'aead_xchacha20poly1305ietf_js.dart';
import 'auth_js.dart';
import 'box_js.dart';
import 'generic_hash_js.dart';
import 'kdf_js.dart';
import 'kx_js.dart';
import 'secret_box_js.dart';
import 'secret_stream_js.dart';
import 'short_hash_js.dart';
import 'sign_js.dart';

/// @nodoc
@internal
class CryptoJS implements Crypto {
  /// @nodoc
  final LibSodiumJS sodium;

  /// @nodoc
  CryptoJS(this.sodium);

  @override
  late final SecretBox secretBox = SecretBoxJS(sodium);

  @override
  late final SecretStream secretStream = SecretStreamJS(sodium);

  @override
  late final Aead aeadChaCha20Poly1305 = AeadChaCha20Poly1305JS(sodium);

  @override
  late final Aead aeadXChaCha20Poly1305IETF =
      AeadXChaCha20Poly1305IEFTJS(sodium);

  @override
  late final Auth auth = AuthJS(sodium);

  @override
  late final Box box = BoxJS(sodium);

  @override
  late final Sign sign = SignJS(sodium);

  @override
  late final GenericHash genericHash = GenericHashJS(sodium);

  @override
  late final ShortHash shortHash = ShortHashJS(sodium);

  @override
  late final Kdf kdf = KdfJS(sodium);

  @override
  late final Kx kx = KxJS(sodium);
}
