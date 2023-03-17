import 'package:meta/meta.dart';

import '../../../libsodium_version.dart';

abstract class PluginTarget {
  @protected
  String get suffix;

  Uri get downloadUrl => Uri.https(
        'download.libsodium.org',
        '/libsodium/releases/libsodium-${libsodium_version.ffi}-stable$suffix',
      );
}
