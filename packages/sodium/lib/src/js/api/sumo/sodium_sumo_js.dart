import 'package:meta/meta.dart';

import '../../../api/key_pair.dart';
import '../../../api/secure_key.dart';
import '../../../api/sumo/crypto_sumo.dart';
import '../../../api/sumo/sodium_sumo.dart';
import '../sodium_js.dart';
import 'crypto_sumo_js.dart';

/// @nodoc
@internal
class SodiumSumoJS extends SodiumJS implements SodiumSumo {
  /// @nodoc
  SodiumSumoJS(super.sodium);

  @override
  // ignore: overridden_fields for api customization
  late final CryptoSumo crypto = CryptoSumoJS(sodium);

  @override
  Future<T> runIsolated<T>(
    SodiumSumoIsolateCallback<T> callback, {
    List<SecureKey> secureKeys = const [],
    List<KeyPair> keyPairs = const [],
  }) async => await runIsolatedWithInstance<T, SodiumSumoJS>(
    this,
    callback,
    secureKeys,
    keyPairs,
  );

  @override
  SodiumSumoFactory get isolateFactory =>
      () => Future.value(this);
}
