import 'package:sodium/src/api/sodium.dart';

abstract class TestCase {
  late Sodium sodium;

  String get name;

  void setupTests();
}
