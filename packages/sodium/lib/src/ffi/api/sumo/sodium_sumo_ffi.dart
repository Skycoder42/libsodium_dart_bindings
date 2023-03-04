import 'package:meta/meta.dart';

import '../../../api/sumo/crypto_sumo.dart';
import '../../../api/sumo/sodium_sumo.dart';
import '../helpers/isolates/libsodiumffi_factory.dart';
import '../sodium_ffi.dart';
import 'crypto_sumo_ffi.dart';

/// @nodoc
@internal
class SodiumSumoFFI extends SodiumFFI implements SodiumSumo {
  /// @nodoc
  SodiumSumoFFI(super.sodium, [super.sodiumFactory]);

  /// @nodoc
  static Future<SodiumSumoFFI> fromFactory(LibSodiumFFIFactory factory) async =>
      SodiumSumoFFI(
        await factory(),
        factory,
      );

  @override
  // ignore: overridden_fields
  late final CryptoSumo crypto = CryptoSumoFFI(sodium);
}
