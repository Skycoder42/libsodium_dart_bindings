import 'dart:io';

import 'plugin_target.dart';

class AndroidTarget extends PluginTarget {
  final String architecture;

  const AndroidTarget(this.architecture);

  @override
  String get name => 'android_$architecture';

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
