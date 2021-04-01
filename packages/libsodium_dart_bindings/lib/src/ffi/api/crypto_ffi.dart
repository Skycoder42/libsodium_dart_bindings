import '../../api/crypto.dart';
import '../../api/pwhash.dart';
import '../bindings/sodium.ffi.dart';
import 'pwhash_ffi.dart';

class CryptoFFI implements Crypto {
  final SodiumFFI sodium;

  CryptoFFI(this.sodium);

  @override
  late final Pwhash pwhash = PwhashFFI(sodium);
}
