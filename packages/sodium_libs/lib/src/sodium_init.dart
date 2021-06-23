import 'package:sodium/sodium.dart' as sodium;

abstract class SodiumInit {
  const SodiumInit._(); // coverage:ignore-line

  static Future<sodium.Sodium> init() => throw UnimplementedError();
}
