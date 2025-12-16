@TestOn('js')
library;

// ignore: dart_test_tools/no_self_package_imports for coverage
import 'package:sodium/sodium.js.dart';
import 'package:test/test.dart';

void main() {
  group('coverage', () {
    test('sodium.js', () {
      const LibSodiumJS? sodium = null;
      expect(sodium, isNull);
    });
  });
}
