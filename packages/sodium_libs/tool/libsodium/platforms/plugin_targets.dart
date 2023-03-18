import 'android_target.dart';
import 'darwin_target.dart';
import 'plugin_target.dart';
import 'windows_target.dart';

abstract class PluginTargets {
  PluginTargets._();

  // ignore: constant_identifier_names
  static const android_arm64_v8a = AndroidTarget('arm64_v8a');
  // ignore: constant_identifier_names
  static const android_armeabi_v7a = AndroidTarget('armeabi_v7a');
  // ignore: constant_identifier_names
  static const android_x86_64 = AndroidTarget('x86_64');
  // ignore: constant_identifier_names
  static const android_x86 = AndroidTarget('x86');
  static const ios = DarwinTarget('ios', 'arm64');
  // ignore: constant_identifier_names
  static const ios_simulator_arm64 = DarwinTarget('ios_simulator', 'arm64');
  // ignore: constant_identifier_names
  static const ios_simulator_x86_64 = DarwinTarget('ios_simulator', 'x86_64');
  // ignore: constant_identifier_names
  static const macos_arm64 = DarwinTarget('macos', 'arm64');
  // ignore: constant_identifier_names
  static const macos_x86_64 = DarwinTarget('macos', 'x86_64');
  static const windows = WindowsTarget();

  static const values = {
    android_arm64_v8a,
    android_armeabi_v7a,
    android_x86_64,
    android_x86,
    ios,
    ios_simulator_arm64,
    ios_simulator_x86_64,
    macos_arm64,
    macos_x86_64,
    windows,
  };

  static PluginTarget fromName(String name) =>
      values.singleWhere((e) => e.name == name);
}
