import 'package:meta/meta.dart';
import 'package:sodium/src/api/box.dart';
import 'package:sodium/src/js/api/box_js.dart';

import '../../api/auth.dart';
import '../../api/crypto.dart';
import '../../api/pwhash.dart';
import '../../api/secret_box.dart';
import '../../api/secret_stream.dart';
import '../bindings/sodium.js.dart' hide SecretBox;
import 'auth_js.dart';
import 'pwhash_js.dart';
import 'secret_box_js.dart';
import 'secret_stream_js.dart';

@internal
class CryptoJS implements Crypto {
  final LibSodiumJS sodium;

  CryptoJS(this.sodium);

  @override
  late final SecretBox secretBox = SecretBoxJS(sodium);

  @override
  late final SecretStream secretStream = SecretStreamJS(sodium);

  @override
  late final Auth auth = AuthJS(sodium);

  @override
  late final Box box = BoxJS(sodium);

  @override
  late final Pwhash pwhash = PwhashJS(sodium);
}
