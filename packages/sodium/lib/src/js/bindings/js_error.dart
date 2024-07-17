import 'dart:js_interop';

import '../../api/sodium_exception.dart';

/// A wrapper around the JS
/// [Error](https://developer.mozilla.org/de/docs/Web/JavaScript/Reference/Global_Objects/Error)
/// type.
@JS('Error')
extension type JSError._(JSObject _) implements JSObject {
  /// @nodoc
  external String get message;

  /// @nodoc
  external JSError([String? message]);
}

/// Wraps any callback to convert [JSError]s to [SodiumException]s.
///
/// This simply runs the [callback] and catches all instances of [JSError] and
/// rethrows the error message as [SodiumException].
T jsErrorWrap<T>(T Function() callback) {
  try {
    return callback();
  } on JSError catch (e, s) {
    Error.throwWithStackTrace(SodiumException(e.message), s);
  }
}
