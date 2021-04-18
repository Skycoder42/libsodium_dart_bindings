import 'pwhash.dart';
import 'secret_box.dart';

abstract class Crypto {
  const Crypto._(); // coverage:ignore-line

  SecretBox get secretBox;

  Pwhash get pwhash;
}
