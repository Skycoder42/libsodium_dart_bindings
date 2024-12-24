import 'dart:io';

import 'android_target.dart';
import 'darwin_target.dart';
import 'linux_target.dart';
import 'plugin_platform.dart';
import 'plugin_target.dart';
import 'windows_target.dart';

typedef PublishCallback = Future<void> Function({
  required PluginTargetGroup group,
  required Directory artifactsDir,
  required Directory archiveDir,
});

typedef ComputeHashCallback = Future<Object> Function(
  File archive,
  String originalHash,
);

class PluginTargetGroup {
  final PluginPlatform platform;
  final List<PluginTarget> targets;
  final PublishCallback? publish;
  final ComputeHashCallback? hash;

  const PluginTargetGroup(
    this.platform,
    this.targets, {
    this.publish,
    this.hash,
  });

  String get name => platform.name;
}

abstract class PluginTargets {
  PluginTargets._();

  static const allTargets = [
    ...AndroidTarget.values,
    ...DarwinTarget.values,
    ...LinuxTarget.values,
    ...WindowsTarget.values,
  ];

  static const targetGroups = [
    PluginTargetGroup(
      PluginPlatform.android,
      AndroidTarget.values,
    ),
    PluginTargetGroup(
      PluginPlatform.darwin,
      DarwinTarget.values,
      publish: DarwinTarget.createXcFramework,
      hash: DarwinTarget.computeHash,
    ),
    PluginTargetGroup(
      PluginPlatform.linux,
      LinuxTarget.values,
    ),
    PluginTargetGroup(
      PluginPlatform.windows,
      WindowsTarget.values,
    ),
  ];

  static PluginTarget fromName(String name) =>
      allTargets.singleWhere((e) => e.name == name);

  static PluginTargetGroup groupFromName(String name) =>
      targetGroups.singleWhere((e) => e.platform.name == name);
}
