import 'android_target.dart';
import 'darwin_target.dart';
import 'plugin_target.dart';
import 'windows_target.dart';

class PluginTargetGroup {
  final String name;
  final List<PluginTarget> targets;
  final bool useLipo;

  const PluginTargetGroup(
    this.name,
    this.targets, {
    this.useLipo = false,
  });
}

abstract class PluginTargets {
  PluginTargets._();

  // ignore: constant_identifier_names
  static const android_arm64_v8a = AndroidTarget(
    architecture: 'arm64_v8a',
    buildTarget: 'armv8-a',
    installTarget: 'armv8-a+crypto',
  );
  // ignore: constant_identifier_names
  static const android_armeabi_v7a = AndroidTarget(
    architecture: 'armeabi_v7a',
    buildTarget: 'armv7-a',
  );
  // ignore: constant_identifier_names
  static const android_x86_64 = AndroidTarget(
    architecture: 'x86_64',
    installTarget: 'westmere',
  );
  // ignore: constant_identifier_names
  static const android_x86 = AndroidTarget(
    architecture: 'x86',
    installTarget: 'i686',
  );
  static const ios = DarwinTarget(
    platform: DarwinPlatform.ios,
    architecture: 'arm64',
    buildTarget: 'arm-apple-darwin10',
  );
  // ignore: constant_identifier_names
  static const ios_simulator_arm64 = DarwinTarget(
    platform: DarwinPlatform.ios_simulator,
    architecture: 'arm64',
    buildTarget: 'arm-apple-darwin20',
  );
  // ignore: constant_identifier_names
  static const ios_simulator_x86_64 = DarwinTarget(
    platform: DarwinPlatform.ios_simulator,
    architecture: 'x86_64',
    buildTarget: 'x86_64-apple-darwin10',
  );
  // ignore: constant_identifier_names
  static const macos_arm64 = DarwinTarget(
    platform: DarwinPlatform.macos,
    architecture: 'arm64',
    buildTarget: 'arm-apple-darwin20',
  );
  // ignore: constant_identifier_names
  static const macos_x86_64 = DarwinTarget(
    platform: DarwinPlatform.macos,
    architecture: 'x86_64',
    buildTarget: 'x86_64-apple-darwin10',
  );
  static const windows = WindowsTarget();

  static const androidTargets = [
    android_arm64_v8a,
    android_armeabi_v7a,
    android_x86_64,
    android_x86,
  ];

  static const iosTargets = [
    ios,
    ios_simulator_arm64,
    ios_simulator_x86_64,
  ];

  static const macosTargets = [
    macos_arm64,
    macos_x86_64,
  ];

  static const windowsTargets = [
    windows,
  ];

  static const allTargets = [
    ...androidTargets,
    ...iosTargets,
    ...macosTargets,
    ...windowsTargets,
  ];

  static const targetGroups = [
    PluginTargetGroup('android', androidTargets),
    PluginTargetGroup('ios', iosTargets, useLipo: true),
    PluginTargetGroup('macos', macosTargets, useLipo: true),
    PluginTargetGroup('windows', windowsTargets),
  ];

  static PluginTarget fromName(String name) =>
      allTargets.singleWhere((e) => e.name == name);
}
