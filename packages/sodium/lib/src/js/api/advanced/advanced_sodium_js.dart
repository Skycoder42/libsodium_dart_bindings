import '../../../../sodium.js.dart';
import '../../../api/advanced/advanced_crypto.dart';
import '../../../api/advanced/advanced_sodium.dart';
import '../sodium_js.dart';
import 'advanced_crypto_js.dart';

class AdvancedSodiumJS extends SodiumJS implements AdvancedSodium {
  AdvancedSodiumJS(LibSodiumJS sodium) : super(sodium);

  @override
  AdvancedCrypto get crypto => _advancedCrypto;
  late final AdvancedCrypto _advancedCrypto = AdvancedCryptoJS(sodium);
}
