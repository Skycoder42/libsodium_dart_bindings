import 'dart:js_interop';

import '../../api/sodium_exception.dart';

/// A wrapper around the JS
/// [Error](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Error)
/// type.
@JS('Error')
extension type JSError._(JSObject _) implements JSObject {
  /// See https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Error/message
  external String get message;

  /// See https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Error/Error
  external JSError([String? message]);
}

/// Wraps any callback to convert [JSError]s to [SodiumException]s.
///
/// This simply runs the [callback] and catches all instances of [JSError] and
/// rethrows the [JSError.message] as [SodiumException].
T jsErrorWrap<T>(T Function() callback) {
  try {
    return callback();
  } on JSError catch (e, s) {
    Error.throwWithStackTrace(SodiumException(e.message), s);
  }
}
