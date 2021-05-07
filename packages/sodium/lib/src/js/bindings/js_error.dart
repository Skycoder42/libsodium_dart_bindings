@JS()
library js_error;

import 'package:js/js.dart';

import '../../api/sodium_exception.dart';

/// A wrapper around the JS
/// [Error](https://developer.mozilla.org/de/docs/Web/JavaScript/Reference/Global_Objects/Error)
/// type.
@JS('Error')
class JsError {
  /// @nodoc
  external String get message;

  /// @nodoc
  external factory JsError([String? message]);

  /// Wraps any callback to convert [JsError]s to [SodiumException]s.
  ///
  /// This simply runs the [callback] and catches all instances of [JsError] and
  /// rethrows the error message as [SodiumException].
  static T wrap<T>(T Function() callback) {
    try {
      return callback();
    } on JsError catch (e) {
      throw SodiumException(e.message);
    }
  }
}
