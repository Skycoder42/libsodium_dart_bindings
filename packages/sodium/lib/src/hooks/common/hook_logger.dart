import 'dart:io';

import 'package:meta/meta.dart';

@internal
// ignore: public_member_api_docs false positive
class HookLogger(final String hook, {final bool logDebug = false}) {
  var _didWriteFirst = false;

  void warning(String message) => _logTo(stderr, 'WARNING', message);

  void info(String message) => _logTo(stdout, 'INFO', message);

  void debug(String message) {
    if (logDebug) {
      _logTo(stdout, 'DEBUG', message);
    }
  }

  void _logTo(IOSink sink, String level, String message) =>
      _logImplementation(logDebug ? stderr : sink, level, message);

  void _logImplementation(IOSink sink, String level, String message) {
    if (!_didWriteFirst) {
      sink.writeln();
    }
    sink.writeln('[$hook] $level: $message');
    _didWriteFirst = true;
  }
}
