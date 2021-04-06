import 'dart:typed_data';

abstract class Randombytes {
  const Randombytes._();

  int get seedBytes;

  int random();

  int uniform(int upperBound);

  Uint8List buf(int size);

  Uint8List bufDeterministic(int size, Uint8List seed);

  void close();

  void stir();
}
