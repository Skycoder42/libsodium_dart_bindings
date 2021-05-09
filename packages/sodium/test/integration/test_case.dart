// dart_pre_commit:ignore-library-import
import 'package:sodium/sodium.dart';

abstract class TestCase {
  late Sodium sodium;

  String get name;

  void setupTests();
}
