import '../../../api/advanced/advanced_crypto.dart';
import '../../../api/advanced/advanced_scalar_mult.dart';
import '../../bindings/libsodium.ffi.dart';
import '../crypto_ffi.dart';
import 'advanced_scalar_mult_ffi.dart';

class AdvancedCryptoFFI extends CryptoFFI implements AdvancedCrypto {
  AdvancedCryptoFFI(LibSodiumFFI sodium) : super(sodium);

  @override
  late final AdvancedScalarMult scalarMult = AdvancedScalarMultFFI(sodium);
}
