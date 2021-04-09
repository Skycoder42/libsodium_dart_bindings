import 'dart:typed_data';

abstract class Randombytes {
  const Randombytes._(); // coverage:ignore-line

  int get seedBytes;

  int random();

  int uniform(int upperBound);

  Uint8List buf(int length);

  Uint8List bufDeterministic(int length, Uint8List seed);

  void close();

  void stir();
}
