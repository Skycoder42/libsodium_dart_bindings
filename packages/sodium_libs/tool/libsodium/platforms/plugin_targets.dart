import '../../../libsodium_version.dart';
import 'android_target.dart';
import 'darwin_target.dart';
import 'linux_target.dart';
import 'plugin_target.dart';
import 'windows_target.dart';

enum PublishKind { rsync, xcFramework }

class PluginTargetGroup {
  final String name;
  final String suffix;
  final List<PluginTarget> targets;
  final String binaryDir;
  final PublishKind publishKind;

  const PluginTargetGroup(
    this.name,
    this.binaryDir,
    this.targets, {
    this.suffix = '.tar.xz',
    this.publishKind = PublishKind.rsync,
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
    platform: 'ios',
    architectures: ['ios64'],
    libraryType: 'a',
  );
  // ignore: constant_identifier_names
  static const ios_simulator = DarwinTarget(
    platform: 'ios_simulator',
    architectures: ['ios-simulator-arm64', 'ios-simulator-x86_64'],
    libraryType: 'a',
  );
  static const macos = DarwinTarget(
    platform: 'macos',
    architectures: ['macos-arm64', 'macos-x86_64'],
    libraryType: 'dylib',
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
    ios_simulator,
  ];

  static const _macosTargets = [
    macos,
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
    ..._iosTargets,
    ..._macosTargets,
    ..._windowsTargets,
    ..._linuxTargets,
  ];

  static const targetGroups = [
    PluginTargetGroup(
      'linux',
      'lib',
      _linuxTargets,
    ),
    PluginTargetGroup(
      'android',
      'src/main/jniLibs',
      _androidTargets,
    ),
    PluginTargetGroup(
      'ios',
      'Libraries',
      _iosTargets,
      publishKind: PublishKind.xcFramework,
    ),
    PluginTargetGroup(
      'macos',
      'Libraries',
      _macosTargets,
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
