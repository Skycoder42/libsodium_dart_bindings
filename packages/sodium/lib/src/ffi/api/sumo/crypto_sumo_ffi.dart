import 'package:meta/meta.dart';

import '../../../api/sumo/crypto_sumo.dart';
import '../../../api/sumo/sign_sumo.dart';
import '../crypto_ffi.dart';
import 'sign_sumo_ffi.dart';

/// @nodoc
@internal
class CryptoSumoFFI extends CryptoFFI implements CryptoSumo {
  /// @nodoc
  CryptoSumoFFI(super.sodium);

  @override
  // ignore: overridden_fields
  late final SignSumo sign = SignSumoFFI(sodium);
}
