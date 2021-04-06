import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:sodium/sodium.dart';

abstract class LibsodiumPlatform extends PlatformInterface {
  static final Object _token = Object();

  static late LibsodiumPlatform _instance;

  LibsodiumPlatform() : super(token: _token);

  static LibsodiumPlatform get instance => _instance;

  static set instance(LibsodiumPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<Sodium> loadSodium();
}
