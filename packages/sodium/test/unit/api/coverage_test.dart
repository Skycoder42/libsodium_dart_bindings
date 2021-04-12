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
