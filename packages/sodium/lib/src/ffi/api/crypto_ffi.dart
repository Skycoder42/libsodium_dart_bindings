import 'package:meta/meta.dart';

import '../../api/crypto.dart';
import '../../api/pwhash.dart';
import '../../api/secret_box.dart';
import '../bindings/libsodium.ffi.dart';
import 'pwhash_ffi.dart';
import 'secret_box_ffi.dart';

@internal
class CryptoFFI implements Crypto {
  final LibSodiumFFI sodium;

  CryptoFFI(this.sodium);

  @override
  late final SecretBox secretBox = SecretBoxFFI(sodium);

  @override
  late final Pwhash pwhash = PwhashFFI(sodium);
}
