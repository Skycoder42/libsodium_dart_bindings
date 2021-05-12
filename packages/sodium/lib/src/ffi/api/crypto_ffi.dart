import 'package:meta/meta.dart';
import 'package:sodium/src/api/box.dart';
import 'package:sodium/src/ffi/api/box_ffi.dart';

import '../../api/auth.dart';
import '../../api/crypto.dart';
import '../../api/pwhash.dart';
import '../../api/secret_box.dart';
import '../../api/secret_stream.dart';
import '../bindings/libsodium.ffi.dart';
import 'auth_ffi.dart';
import 'pwhash_ffi.dart';
import 'secret_box_ffi.dart';
import 'secret_stream_ffi.dart';

@internal
class CryptoFFI implements Crypto {
  final LibSodiumFFI sodium;

  CryptoFFI(this.sodium);

  @override
  late final SecretBox secretBox = SecretBoxFFI(sodium);

  @override
  late final SecretStream secretStream = SecretStreamFFI(sodium);

  @override
  late final Auth auth = AuthFFI(sodium);

  @override
  late final Box box = BoxFFI(sodium);

  @override
  late final Pwhash pwhash = PwhashFFI(sodium);
}
