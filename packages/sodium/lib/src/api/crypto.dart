import 'pwhash.dart';
import 'secret_box.dart';
import 'secret_stream.dart';

abstract class Crypto {
  const Crypto._(); // coverage:ignore-line

  SecretBox get secretBox;

  SecretStream get secretStream;

  Pwhash get pwhash;
}
