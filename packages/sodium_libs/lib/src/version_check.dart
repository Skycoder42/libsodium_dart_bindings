import 'package:flutter/foundation.dart';
import 'package:sodium/sodium.dart';

import 'sodium_platform.dart';

/// @nodoc
@internal
class VersionCheck {
  static const _expectedVersion = SodiumVersion(26, 2, '1.0.20');

  VersionCheck._();

  /// @nodoc
  static void check(SodiumPlatform platform, Sodium instance) {
    assert(kDebugMode, 'Version check should only be run in debug mode!');

    if (instance.version < _expectedVersion) {
      // ignore: avoid_print for debug code
      print(
        'WARNING: The embedded libsodium is outdated! '
        'Expected $_expectedVersion, but was ${instance.version}}. '
        '${platform.updateHint}',
      );
    }
  }
}
