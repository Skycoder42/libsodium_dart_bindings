@TestOn('js')
library;

import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/js/bindings/js_error.dart';
import 'package:test/test.dart';

void main() {
  group('wrap', () {
    test('returns value on success', () {
      const value = 'value';

      final res = jsErrorWrap(() => value);

      expect(res, value);
    });

    test('throws SodiumException on js error', () {
      const message = 'error-message';

      expect(
        // ignore: only_throw_errors for testing
        () => jsErrorWrap(() => throw JSError(message)),
        throwsA(
          isA<SodiumException>().having(
            (e) => e.originalMessage,
            'originalMessage',
            message,
          ),
        ),
      );
    });

    test('throws SodiumException on other exception type', () {
      const message = 'error-message';

      expect(
        // ignore: only_throw_errors for testing
        () => jsErrorWrap(() => throw message),
        throwsA(
          isA<SodiumException>().having(
            (e) => e.originalMessage,
            'originalMessage',
            message,
          ),
        ),
      );
    });
  });
}
