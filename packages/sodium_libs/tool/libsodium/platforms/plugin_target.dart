import 'dart:io';

import 'package:meta/meta.dart';

import '../../../libsodium_version.dart';

@immutable
abstract class PluginTarget {
  const PluginTarget();

  @protected
  String get name;

  @protected
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
