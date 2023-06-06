@TestOn('dart-vm')
library coverage_test;

// ignore: no_self_package_imports
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
