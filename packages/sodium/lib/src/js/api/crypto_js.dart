import 'package:meta/meta.dart';

import '../../api/auth.dart';
import '../../api/crypto.dart';
import '../../api/pwhash.dart';
import '../../api/secret_box.dart';
import '../../api/secret_stream.dart';
import '../bindings/sodium.js.dart' hide SecretBox;
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
  late final Pwhash pwhash = PwhashJS(sodium);

  @override
  // TODO: implement auth
  Auth get auth => throw UnimplementedError();
}
