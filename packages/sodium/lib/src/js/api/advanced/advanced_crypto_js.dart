import '../../../../sodium.js.dart';
import '../../../api/advanced/advanced_crypto.dart';
import '../../../api/advanced/advanced_scalar_mult.dart';
import '../crypto_js.dart';
import 'advanced_scalar_mult_js.dart';

class AdvancedCryptoJS extends CryptoJS implements AdvancedCrypto {
  AdvancedCryptoJS(LibSodiumJS sodium) : super(sodium);

  @override
  late final AdvancedScalarMult scalarMult = AdvancedScalarMultJS(sodium);
}
