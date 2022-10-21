import 'package:meta/meta.dart';

import '../../../api/sumo/crypto_sumo.dart';
import '../../../api/sumo/sign_sumo.dart';
import '../crypto_js.dart';
import 'sign_sumo_js.dart';

/// @nodoc
@internal
class CryptoSumoJS extends CryptoJS implements CryptoSumo {
  /// @nodoc
  CryptoSumoJS(super.sodium);

  @override
  // ignore: overridden_fields
  late final SignSumo sign = SignSumoJS(sodium);
}
