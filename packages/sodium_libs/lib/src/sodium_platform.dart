import 'package:meta/meta.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:sodium/sodium.dart';

abstract class SodiumPlatform extends PlatformInterface {
  static final Object _token = Object();

  static SodiumPlatform? _instance;

  SodiumPlatform() : super(token: _token);

  static SodiumPlatform get instance => _instance!;

  @internal
  static bool get isRegistered => _instance != null;

  static set instance(SodiumPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<Sodium> loadSodium();
}
