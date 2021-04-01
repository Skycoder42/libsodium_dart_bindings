import 'package:libsodium_dart_bindings/libsodium_dart_bindings.dart';
import 'package:libsodium_flutter_bindings_platform_interface/libsodium_flutter_bindings_platform_interface.dart';

class SodiumInit {
  // ignore: prefer_constructors_over_static_methods
  static SodiumInit get instance =>
      SodiumInit.fromPlatform(LibsodiumPlatform.instance);

  static Future<Sodium> init() => instance();

  final LibsodiumPlatform libsodiumPlatform;

  const SodiumInit.fromPlatform(this.libsodiumPlatform);

  Future<Sodium> call() => libsodiumPlatform.loadSodium();
}
