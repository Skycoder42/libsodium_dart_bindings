import 'package:sodium/sodium.dart';
import 'package:sodium/sodium.ffi.dart';
import 'package:test/test.dart';

void main() {
  group('coverage', () {
    test('sodium', () {
      const Sodium? sodium = null;
      expect(sodium, isNull);
    });

    test('sodium.ffi', () {
      const SodiumFFI? sodiumFFI = null;
      expect(sodiumFFI, isNull);
    });
  });
}
