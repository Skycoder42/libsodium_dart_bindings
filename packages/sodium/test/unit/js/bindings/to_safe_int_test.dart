import 'package:sodium/src/js/bindings/to_safe_int.dart';
import 'package:test/test.dart';

void main() {
  group('toSafeInt', () {
    test('returns value below max', () {
      const num value = 42;
      final res = value.toSafeInt();

      expect(res, value);
    });

    test('returns maxSafeInteger above max', () {
      const num value = ToSafeIntX.maxSafeInteger + 1;
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
      const num value = ToSafeIntX.maxSafeInteger + 1;
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
