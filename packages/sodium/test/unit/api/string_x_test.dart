import 'package:sodium/src/api/string_x.dart';
import 'package:test/test.dart';

void main() {
  group('toCharArray', () {
    test('converts string to utf8 pointer', () {
      const testStr = 'ABC';
      final res = testStr.toCharArray();
      expect(res, const [0x41, 0x42, 0x43]);
    });

    test('continues encoding after 0 terminator', () {
      const testStr = 'AB\x00CD';
      final res = testStr.toCharArray();
      expect(res, const [0x41, 0x42, 0x00, 0x43, 0x44]);
    });
  });
}
