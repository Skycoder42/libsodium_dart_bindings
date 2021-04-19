@JS()
library js_error;

import 'package:js/js.dart';

import '../../api/sodium_exception.dart';

@JS('Error')
class JsError {
  external String get message;

  external factory JsError([String? message]);

  static T wrap<T>(T Function() callback) {
    try {
      return callback();
    } on JsError catch (e) {
      throw SodiumException(e.message);
    }
  }
}
