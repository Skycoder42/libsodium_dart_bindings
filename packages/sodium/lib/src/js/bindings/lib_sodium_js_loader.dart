// coverage:ignore-file

import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'sodium.js.dart';

extension type _SodiumBrowserInit._(JSObject _) implements JSObject {
  external JSFunction get onload;

  external _SodiumBrowserInit({JSFunction onload});
}

@JS('sodium')
external _SodiumBrowserInit? get _sodium;

@JS('sodium')
external set _sodium(_SodiumBrowserInit? value);

/// A helper class that interacts with sodium.js to get the loaded sodium
/// instance.
sealed class LibSodiumJSLoader {
  /// Obtain the raw [LibSodiumJS] instance from the browser.
  ///
  /// This method uses the standard browser loading mechanisms for libsodium.js
  /// to get the loaded instance.
  ///
  /// **Important:** This will only work if the libsodium.js script is already
  /// loaded somewhere in the browser!
  static Future<LibSodiumJS> loadLibSodiumJS() {
    // check if sodium.js script was already loaded
    if (_sodium case final sodiumObj? when sodiumObj.isA<JSObject>()) {
      if (sodiumObj.has('ready')) {
        final sodium = sodiumObj as LibSodiumJS;
        return sodium.ready.toDart.then((_) => sodium);
      }
    }

    // if not, overwrite sodium window property with a custom onload
    final completer = Completer<LibSodiumJS>();
    void onload(LibSodiumJS sodium) => completer.complete(sodium);
    _sodium = _SodiumBrowserInit(onload: onload.toJS);
    return completer.future;
  }
}
