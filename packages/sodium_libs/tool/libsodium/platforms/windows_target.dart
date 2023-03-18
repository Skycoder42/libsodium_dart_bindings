import 'dart:io';

import 'package:meta/meta.dart';

import 'plugin_target.dart';

@immutable
class WindowsTarget extends PluginTarget {
  const WindowsTarget();

  @override
  String get name => 'windows';

  @override
  String get suffix => '-msvc.zip';

  @override
  Future<void> build({
    required Directory extractDir,
    required Directory artifactDir,
  }) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
