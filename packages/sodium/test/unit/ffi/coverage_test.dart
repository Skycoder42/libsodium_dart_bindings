@TestOn('dart-vm')

// ignore: test_library_import
import 'package:sodium/sodium.ffi.dart';
import 'package:test/test.dart';

void main() {
  group('coverage', () {
    test('sodium.ffi', () {
      const LibSodiumFFI? sodiumFFI = null;
      expect(sodiumFFI, isNull);
    });
  });
}
