import 'package:libsodium_dart_bindings/src/api/crypto.dart';
import 'package:libsodium_dart_bindings/src/api/pwhash.dart';
import 'package:libsodium_dart_bindings/src/js/api/pwhash_js.dart';

class CrypoJS implements Crypto {
  @override
  late final Pwhash pwhash = PwhashJs();
}
