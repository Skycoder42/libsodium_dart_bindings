import '../../../api/advanced/advanced_crypto.dart';
import '../../../api/advanced/advanced_sodium.dart';
import '../../bindings/libsodium.ffi.dart';
import '../sodium_ffi.dart';
import 'advanced_crypto_ffi.dart';

class AdvancedSodiumFFI extends SodiumFFI implements AdvancedSodium {
  AdvancedSodiumFFI(LibSodiumFFI sodium) : super(sodium);

  @override
  AdvancedCrypto get crypto => _crypto;
  late final AdvancedCrypto _crypto = AdvancedCryptoFFI(sodium);
}
