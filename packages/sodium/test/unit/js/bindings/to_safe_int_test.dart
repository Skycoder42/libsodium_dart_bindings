import 'package:sodium/src/js/bindings/to_safe_int.dart';
import 'package:test/test.dart';

void main() {
  test('maxSafeInteger returns correct value', () {
    const value = 9007199254740991;
    expect(ToSafeIntX.maxSafeInteger, value);
  });

  group('toSafeUInt32', () {
    test('returns value below max', () {
      const num value = 42;
      final res = value.toSafeUInt32();

      expect(res, value);
    });

    test('returns uint32Max above max', () {
      final num value = ToSafeIntX.uint32Max + 1;
      final res = value.toSafeUInt32();

      expect(res, ToSafeIntX.uint32Max);
    });

    test('returns maxSafeInteger for values below 0', () {
      const num value = -1;
      final res = value.toSafeUInt32();

      expect(res, ToSafeIntX.uint32Max);
    });
  });

  group('toSafeUInt64', () {
    test('returns value below max', () {
      const num value = 42;
      final res = value.toSafeUInt64();

      expect(res, value);
    });

    test('returns maxSafeInteger above max', () {
      final num value = ToSafeIntX.maxSafeInteger + 1;
      final res = value.toSafeUInt64();

      expect(res, ToSafeIntX.maxSafeInteger);
    });

    test('returns maxSafeInteger for values below 0', () {
      const num value = -1;
      final res = value.toSafeUInt64();

      expect(res, ToSafeIntX.maxSafeInteger);
    });
  });
}
