import 'package:flutter/widgets.dart';
import 'package:sodium/sodium.dart' as sodium;
import 'package:sodium_libs/src/dart_plugin_stub.dart';
import 'package:sodium_libs_platform_interface/sodium_libs_platform_interface.dart';

abstract class SodiumInit {
  const SodiumInit._(); // coverage:ignore-line

  static Future<sodium.Sodium> init() {
    WidgetsFlutterBinding.ensureInitialized();
    registerDartPlugins();
    return SodiumPlatform.instance.loadSodium();
  }
}
