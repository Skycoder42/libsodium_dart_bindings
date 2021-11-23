@OnPlatform(<String, dynamic>{'!dart-vm': Skip('Requires dart:ffi')})

// dart_pre_commit:ignore-library-import
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
