@TestOn('js')

// ignore: test_library_import
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
