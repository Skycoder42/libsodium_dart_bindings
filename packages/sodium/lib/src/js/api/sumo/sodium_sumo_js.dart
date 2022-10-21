import 'package:meta/meta.dart';

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
  // ignore: overridden_fields
  late final CryptoSumo crypto = CryptoSumoJS(sodium);
}
