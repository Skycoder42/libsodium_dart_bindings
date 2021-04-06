import 'dart:js';

import '../../api/crypto.dart';
import '../../api/pwhash.dart';

import 'pwhash_js.dart';

class CrypoJS implements Crypto {
  final JsObject sodium;

  CrypoJS(this.sodium);

  @override
  Pwhash get pwhash => PwhashJs(sodium);
}
