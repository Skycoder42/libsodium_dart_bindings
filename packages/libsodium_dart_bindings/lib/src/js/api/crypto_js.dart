import 'dart:js';

import 'package:libsodium_dart_bindings/src/api/crypto.dart';
import 'package:libsodium_dart_bindings/src/api/pwhash.dart';
import 'package:libsodium_dart_bindings/src/js/api/pwhash_js.dart';

class CrypoJS implements Crypto {
  final JsObject sodium;

  CrypoJS(this.sodium);

  @override
  Pwhash get pwhash => PwhashJs(sodium);
}
