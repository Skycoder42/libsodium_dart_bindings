import '../sodium.dart';
import 'advanced_crypto.dart';

abstract class AdvancedSodium implements Sodium {
  @override
  AdvancedCrypto get crypto;
}
