import 'package:meta/meta.dart';

import '../../api/crypto.dart';
import '../../api/pwhash.dart';
import '../../api/secret_box.dart';
import '../bindings/sodium.js.dart' hide SecretBox;
import 'pwhash_js.dart';
import 'secret_box_js.dart';

@internal
class CryptoJS implements Crypto {
  final LibSodiumJS sodium;

  CryptoJS(this.sodium);

  @override
  late final SecretBox secretBox = SecretBoxJS(sodium);

  @override
  late final Pwhash pwhash = PwhashJS(sodium);
}
