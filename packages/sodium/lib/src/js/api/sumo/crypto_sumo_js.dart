import 'package:meta/meta.dart';

import '../../../api/sumo/crypto_sumo.dart';
import '../../../api/sumo/pwhash.dart';
import '../../../api/sumo/scalarmult.dart';
import '../../../api/sumo/sign_sumo.dart';
import '../crypto_js.dart';
import 'pwhash_js.dart';
import 'scalarmult_js.dart';
import 'sign_sumo_js.dart';

/// @nodoc
@internal
class CryptoSumoJS extends CryptoJS implements CryptoSumo {
  /// @nodoc
  CryptoSumoJS(super.sodium);

  @override
  // ignore: overridden_fields for api customization
  late final SignSumo sign = SignSumoJS(sodium);

  @override
  late final Pwhash pwhash = PwhashJS(sodium);

  @override
  late final Scalarmult scalarmult = ScalarmultJS(sodium);
}
