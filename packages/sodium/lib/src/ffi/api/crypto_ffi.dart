import '../../api/crypto.dart';
import '../../api/pwhash.dart';
import '../bindings/libsodium.ffi.dart';
import 'pwhash_ffi.dart';

class CryptoFFI implements Crypto {
  final LibSodiumFFI sodium;

  CryptoFFI(this.sodium);

  @override
  late final Pwhash pwhash = PwhashFFI(sodium);
}
