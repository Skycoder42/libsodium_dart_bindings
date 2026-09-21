// coverage:ignore-file

import 'package:meta/meta.dart';

import '../../api/key_pair.dart';
import '../../api/secure_key.dart';
import '../../api/transferrable_secure_key.dart';

@internal
// ignore: public_member_api_docs false positive
class const TransferrableSecureKeyJS(final SecureKey secureKey)
    implements TransferrableSecureKey;

@internal
// ignore: public_member_api_docs false positive
class const TransferrableKeyPairJS(final KeyPair keyPair)
    implements TransferrableKeyPair;
