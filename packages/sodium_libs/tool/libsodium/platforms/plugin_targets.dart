import 'plugin_target.dart';
import 'windows.dart';

abstract class PluginTargets {
  PluginTargets._();

  static List<PluginTarget> get values => [
        Windows(),
      ];
}
