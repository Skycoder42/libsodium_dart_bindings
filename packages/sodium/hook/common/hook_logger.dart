import 'dart:io';

class HookLogger {
  /// special environment variable to enable debug logging. Must be prefixed by
  /// "NIX_" as otherwise it would be stripped.
  ///
  /// See https://dart.dev/tools/hooks#environment-variables
  static const debugLogEnvVar = 'NIX_HOOKS_ENABLE_DEBUG_LOGGING';

  static final _logDebug = Platform.environment[debugLogEnvVar] == '1';

  final String hook;

  HookLogger(this.hook);

  void warning(String message) => _logTo(stderr, 'WARNING', message);

  void info(String message) => _logTo(stdout, 'INFO', message);

  void debug(String message) {
    if (_logDebug) {
      _logTo(stdout, 'DEBUG', message);
    }
  }

  void _logTo(IOSink sink, String level, String message) =>
      sink.writeln('[$hook] $level: $message');
}
