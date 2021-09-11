import '../crypto.dart';
import 'advanced_scalar_mult.dart';

abstract class AdvancedCrypto implements Crypto {
  const AdvancedCrypto._(); // coverage:ignore-line

  // @override
  // AdvancedSecretStream get secretStream;

  AdvancedScalarMult get scalarMult;
}
