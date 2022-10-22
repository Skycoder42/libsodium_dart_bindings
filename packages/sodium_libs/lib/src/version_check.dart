import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:sodium/sodium.dart';

import 'sodium_platform.dart';

/// @nodoc
@internal
class VersionCheck {
  static const _expectedVersion = SodiumVersion(10, 3, '1.0.18');

  VersionCheck._();

  /// @nodoc
  static void check(SodiumPlatform platform, Sodium instance) {
    // ignore: prefer_asserts_with_message
    assert(!kReleaseMode);

    if (instance.version < _expectedVersion) {
      // ignore: avoid_print
      print(
        'WARNING: The embedded libsodium is outdated! '
        'Expected $_expectedVersion, but was ${instance.version}}. '
        '${platform.updateHint}',
      );
    }
  }
}
