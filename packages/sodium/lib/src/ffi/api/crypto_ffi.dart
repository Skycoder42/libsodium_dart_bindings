import 'package:meta/meta.dart';

import '../../api/aead.dart';
import '../../api/auth.dart';
import '../../api/box.dart';
import '../../api/crypto.dart';
import '../../api/generic_hash.dart';
import '../../api/kdf.dart';
import '../../api/pwhash.dart';
import '../../api/secret_box.dart';
import '../../api/secret_stream.dart';
import '../../api/short_hash.dart';
import '../../api/sign.dart';
import '../bindings/libsodium.ffi.dart';
import 'aead_ffi.dart';
import 'auth_ffi.dart';
import 'box_ffi.dart';
import 'generic_hash_ffi.dart';
import 'kdf_ffi.dart';
import 'pwhash_ffi.dart';
import 'secret_box_ffi.dart';
import 'secret_stream_ffi.dart';
import 'short_hash_ffi.dart';
import 'sign_ffi.dart';

@internal
class CryptoFFI implements Crypto {
  final LibSodiumFFI sodium;

  CryptoFFI(this.sodium);

  @override
  late final SecretBox secretBox = SecretBoxFFI(sodium);

  @override
  late final SecretStream secretStream = SecretStreamFFI(sodium);

  @override
  late final Aead aead = AeadFFI(sodium);

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
  late final Pwhash pwhash = PwhashFFI(sodium);

  @override
  late final Kdf kdf = KdfFFI(sodium);
}
