import 'dart:io';

import 'plugin_target.dart';

class DarwinTarget extends PluginTarget {
  final String platform;
  final String architecture;

  const DarwinTarget(this.platform, this.architecture);

  @override
  String get name => platform;

  @override
  String get suffix => '.tar.gz';

  @override
  Future<void> build({
    required Directory extractDir,
    required Directory artifactDir,
  }) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
