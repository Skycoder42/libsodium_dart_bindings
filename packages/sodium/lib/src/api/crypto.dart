import 'pwhash.dart';

abstract class Crypto {
  const Crypto._(); // coverage:ignore-line

  Pwhash get pwhash;
}
