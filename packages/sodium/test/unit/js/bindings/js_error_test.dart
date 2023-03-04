@TestOn('js')
library js_error_test;

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

    test('throws SodiumException on error', () {
      const message = 'error-message';

      expect(
        // ignore: only_throw_errors
        () => jsErrorWrap(() => throw JsError(message)),
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
