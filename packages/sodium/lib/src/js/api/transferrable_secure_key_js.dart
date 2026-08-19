// coverage:ignore-file

import 'package:meta/meta.dart';

import '../../api/key_pair.dart';
import '../../api/secure_key.dart';
import '../../api/transferrable_secure_key.dart';

@internal
class TransferrableSecureKeyJS implements TransferrableSecureKey {
  final SecureKey secureKey;

  const new(this.secureKey);
}

@internal
class TransferrableKeyPairJS implements TransferrableKeyPair {
  final KeyPair keyPair;

  const new(this.keyPair);
}
