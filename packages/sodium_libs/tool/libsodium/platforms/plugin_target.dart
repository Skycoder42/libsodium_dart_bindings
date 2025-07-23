import 'dart:io';

import '../../../libsodium_version.dart';

abstract class PluginTarget {
  const PluginTarget();

  String get name;

  String get suffix;

  Uri get downloadUrl => Uri.https(
    'download.libsodium.org',
    '/libsodium/releases/libsodium-${libsodium_version.ffi}-stable$suffix',
  );

  Future<void> build({
    required Directory extractDir,
    required Directory artifactDir,
  });
}
