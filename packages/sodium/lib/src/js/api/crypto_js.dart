import 'package:meta/meta.dart';

import '../../api/crypto.dart';
import '../../api/pwhash.dart';
import '../bindings/sodium.js.dart';
import 'pwhash_js.dart';

@internal
class CryptoJS implements Crypto {
  final LibSodiumJS sodium;

  CryptoJS(this.sodium);

  @override
  late final Pwhash pwhash = PwhashJs(sodium);
}
