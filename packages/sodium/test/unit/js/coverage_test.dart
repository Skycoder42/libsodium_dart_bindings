@TestOn('js')
library coverage_test;

// ignore: no_self_package_imports
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
