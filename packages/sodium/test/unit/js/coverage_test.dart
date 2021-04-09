import 'package:sodium/sodium.dart';
import 'package:sodium/sodium.js.dart';
import 'package:test/test.dart';

void main() {
  group('coverage', () {
    test('sodium', () {
      const Sodium? sodium = null;
      expect(sodium, isNull);
    });

    test('sodium.js', () {
      const SodiumJS? sodium = null;
      expect(sodium, isNull);
    });
  });
}
