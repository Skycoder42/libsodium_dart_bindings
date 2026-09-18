import 'package:meta/meta.dart';

import '../../../api/key_pair.dart';
import '../../../api/secure_key.dart';
import '../../../api/sodium.dart';
import '../../../api/sumo/crypto_sumo.dart';
import '../../../api/sumo/sodium_sumo.dart';
import '../sodium_js.dart';
import 'crypto_sumo_js.dart';

@internal
// ignore: public_member_api_docs false positive
class SodiumSumoJS(super.sodium) extends SodiumJS implements SodiumSumo {
  @override
  // ignore: overridden_fields for api customization
  late final CryptoSumo crypto = CryptoSumoJS(sodium);

  @override
  Future<T> runIsolated<T>(
    SodiumIsolateCallback<T> callback, {
    List<SecureKey> secureKeys = const [],
    List<KeyPair> keyPairs = const [],
  }) async => await runIsolatedWithInstance<T, SodiumSumoJS>(
    this,
    callback,
    secureKeys,
    keyPairs,
  );
}
