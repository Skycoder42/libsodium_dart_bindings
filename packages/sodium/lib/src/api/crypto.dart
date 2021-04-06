import 'pwhash.dart';

abstract class Crypto {
  const Crypto._();

  Pwhash get pwhash;
}
