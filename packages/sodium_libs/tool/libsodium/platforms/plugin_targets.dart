import 'dart:io';

import '../../../libsodium_version.dart';
import 'android_target.dart';
import 'darwin_target.dart';
import 'linux_target.dart';
import 'plugin_target.dart';
import 'windows_target.dart';

typedef PublishCallback = Future<void> Function({
  required PluginTargetGroup group,
  required Directory artifactsDir,
  required Directory archiveDir,
});

typedef ExtractCallback = Future<void> Function({
  required File verifiedArchive,
  required Directory targetDir,
});

class PluginTargetGroup {
  final String name;
  final String suffix;
  final List<PluginTarget> targets;
  final String binaryDir;
  final PublishCallback? publish;
  final ExtractCallback? extract;

  const PluginTargetGroup(
    this.name,
    this.binaryDir,
    this.targets, {
    this.suffix = '.tar.xz',
    this.publish,
    this.extract,
  });

  String get artifactName => 'libsodium-${libsodium_version.ffi}-$name$suffix';

  Uri get downloadUrl => Uri.https(
        'github.com',
        '/Skycoder42/libsodium_dart_bindings/releases/download/libsodium-binaries/v${libsodium_version.ffi}/$artifactName',
      );
}

abstract class PluginTargets {
  PluginTargets._();

  // ignore: constant_identifier_names
  static const linux_x86_64 = LinuxTarget(architecture: 'x86_64');
  // ignore: constant_identifier_names
  static const linux_aarch64 = LinuxTarget(architecture: 'aarch64');
  // ignore: constant_identifier_names
  static const android_arm64_v8a = AndroidTarget(
    architecture: 'arm64-v8a',
    buildTarget: 'armv8-a',
    installTarget: 'armv8-a+crypto',
  );
  // ignore: constant_identifier_names
  static const android_armeabi_v7a = AndroidTarget(
    architecture: 'armeabi-v7a',
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
    buildTarget: 'aarch64-apple-darwin23',
  );
  // ignore: constant_identifier_names
  static const ios_simulator_arm64 = DarwinTarget(
    platform: DarwinPlatform.ios_simulator,
    architecture: 'arm64',
    buildTarget: 'aarch64-apple-darwin23',
  );
  // ignore: constant_identifier_names
  static const ios_simulator_x86_64 = DarwinTarget(
    platform: DarwinPlatform.ios_simulator,
    architecture: 'x86_64',
    buildTarget: 'x86_64-apple-darwin23',
  );
  // ignore: constant_identifier_names
  static const macos_arm64 = DarwinTarget(
    platform: DarwinPlatform.macos,
    architecture: 'arm64',
    buildTarget: 'aarch64-apple-darwin23',
  );
  // ignore: constant_identifier_names
  static const macos_x86_64 = DarwinTarget(
    platform: DarwinPlatform.macos,
    architecture: 'x86_64',
    buildTarget: 'x86_64-apple-darwin23',
  );
  static const windows = WindowsTarget();

  static const _androidTargets = [
    android_arm64_v8a,
    android_armeabi_v7a,
    android_x86_64,
    android_x86,
  ];

  static const _iosTargets = [
    ios,
    ios_simulator_arm64,
    ios_simulator_x86_64,
  ];

  static const _macosTargets = [
    macos_arm64,
    macos_x86_64,
  ];

  static const _darwinTargets = [
    ..._iosTargets,
    ..._macosTargets,
  ];

  static const _windowsTargets = [
    windows,
  ];

  static const _linuxTargets = [
    linux_x86_64,
    linux_aarch64,
  ];

  static const allTargets = [
    ..._androidTargets,
    ..._darwinTargets,
    ..._windowsTargets,
    ..._linuxTargets,
  ];

  static const targetGroups = [
    PluginTargetGroup(
      'android',
      'libsodium',
      _androidTargets,
    ),
    PluginTargetGroup(
      'darwin',
      'Libraries',
      _darwinTargets,
      publish: DarwinTarget.createXcFramework,
      extract: DarwinTarget.createChecksum,
    ),
    PluginTargetGroup(
      'linux',
      'lib',
      _linuxTargets,
    ),
    PluginTargetGroup(
      'windows',
      'lib',
      _windowsTargets,
      suffix: '.zip',
    ),
  ];

  static PluginTarget fromName(String name) =>
      allTargets.singleWhere((e) => e.name == name);

  static PluginTargetGroup groupFromName(String name) =>
      targetGroups.singleWhere((e) => e.name == name);
}
