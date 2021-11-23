@OnPlatform(<String, dynamic>{'!js': Skip('Requires dart:js')})

// dart_pre_commit:ignore-library-import
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
