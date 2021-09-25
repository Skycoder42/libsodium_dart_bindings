import '../crypto.dart';
import 'advanced_scalar_mult.dart';

abstract class AdvancedCrypto implements Crypto {
  const AdvancedCrypto._(); // coverage:ignore-line

  /// An instance of [AdvancedScalarMult].
  ///
  /// This provides all APIs that start with `crypto_scalarmult`.
  AdvancedScalarMult get scalarMult;
}
