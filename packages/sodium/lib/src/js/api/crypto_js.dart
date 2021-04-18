import 'package:meta/meta.dart';
import 'package:sodium/src/api/secret_box.dart';

import '../../api/crypto.dart';
import '../../api/pwhash.dart';
import '../bindings/sodium.js.dart' hide SecretBox;
import 'pwhash_js.dart';

@internal
class CryptoJS implements Crypto {
  final LibSodiumJS sodium;

  CryptoJS(this.sodium);

  @override
  // TODO: implement secretBox
  SecretBox get secretBox => throw UnimplementedError();

  @override
  late final Pwhash pwhash = PwhashJs(sodium);
}
