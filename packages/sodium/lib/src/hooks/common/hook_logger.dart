import 'dart:io';

import 'package:meta/meta.dart';

@internal
// ignore: public_member_api_docs false positive
class HookLogger(final String hook, {final bool logDebug = false}) {
  void warning(String message) => _logTo(stderr, 'WARNING', message);

  void info(String message) => _logTo(stdout, 'INFO', message);

  void debug(String message) {
    if (logDebug) {
      _logTo(stdout, 'DEBUG', message);
    }
  }

  void _logTo(IOSink sink, String level, String message) =>
      (logDebug ? stderr : sink).writeln('[$hook] $level: $message');
}
