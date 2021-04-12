import 'package:sodium/src/js/bindings/to_safe_int.dart';
import 'package:test/test.dart';

void main() {
  test('maxSafeInteger returns correct value', () {
    const value = 9007199254740991;
    expect(ToSafeIntX.maxSafeInteger, value);
  });

  group('toSafeInt', () {
    test('returns value below max', () {
      const num value = 42;
      final res = value.toSafeInt();

      expect(res, value);
    });

    test('returns maxSafeInteger above max', () {
      final num value = ToSafeIntX.maxSafeInteger + 1;
      final res = value.toSafeInt();

      expect(res, ToSafeIntX.maxSafeInteger);
    });
  });

  group('toSafeUInt', () {
    test('returns value below max', () {
      const num value = 42;
      final res = value.toSafeUInt();

      expect(res, value);
    });

    test('returns maxSafeInteger above max', () {
      final num value = ToSafeIntX.maxSafeInteger + 1;
      final res = value.toSafeUInt();

      expect(res, ToSafeIntX.maxSafeInteger);
    });

    test('returns maxSafeInteger for values below 0', () {
      const num value = -1;
      final res = value.toSafeUInt();

      expect(res, ToSafeIntX.maxSafeInteger);
    });
  });
}
