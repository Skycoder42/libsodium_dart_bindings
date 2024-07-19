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
import '../bindings/libsodium.ffi.dart';
import 'aead_chacha20poly1305_ffi.dart';
import 'aead_xchacha20poly1305ietf_ffi.dart';
import 'auth_ffi.dart';
import 'box_ffi.dart';
import 'generic_hash_ffi.dart';
import 'kdf_ffi.dart';
import 'kx_ffi.dart';
import 'secret_box_ffi.dart';
import 'secret_stream_ffi.dart';
import 'short_hash_ffi.dart';
import 'sign_ffi.dart';

/// @nodoc
@internal
class CryptoFFI implements Crypto {
  /// @nodoc
  final LibSodiumFFI sodium;

  /// @nodoc
  CryptoFFI(this.sodium);

  @override
  late final SecretBox secretBox = SecretBoxFFI(sodium);

  @override
  late final SecretStream secretStream = SecretStreamFFI(sodium);

  @override
  late final Aead aeadChaCha20Poly1305 = AeadChacha20Poly1305FFI(sodium);

  @override
  late final Aead aeadXChaCha20Poly1305IETF =
      AeadXChaCha20Poly1305IETFFFI(sodium);

  @override
  late final Auth auth = AuthFFI(sodium);

  @override
  late final Box box = BoxFFI(sodium);

  @override
  late final Sign sign = SignFFI(sodium);

  @override
  late final GenericHash genericHash = GenericHashFFI(sodium);

  @override
  late final ShortHash shortHash = ShortHashFFI(sodium);

  @override
  late final Kdf kdf = KdfFFI(sodium);

  @override
  late final Kx kx = KxFFI(sodium);
}
