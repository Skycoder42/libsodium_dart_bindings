// ignore: dart_test_tools/no_self_package_imports for coverage
import 'package:sodium/sodium.dart';
import 'package:test/test.dart';

void main() {
  group('coverage', () {
    test('sodium', () {
      const Sodium? sodium = null;
      expect(sodium, isNull);
    });
  });
}
