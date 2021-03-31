import 'package:libsodium_dart_bindings/src/api/crypto.dart';
import 'package:libsodium_dart_bindings/src/js/api/crypto_js.dart';

abstract class SodiumJSInit {
  const SodiumJSInit._();

  static Crypto init() => CrypoJS();
}
