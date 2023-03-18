// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';

class GithubLogger {
  GithubLogger._();

  static void logDebug(String message) => print('::debug::$message');

  static void logInfo(String message) => print('Info: $message');

  static void logNotice(String message) => print('::notice::$message');

  static void logWarning(String message) => print('::warning::$message');

  static void logError(String message) => print('::error::$message');

  static T logGroup<T>(String title, T Function() body) {
    print('::group::$title');
    try {
      return body();
    } finally {
      print('::endgroup::');
    }
  }

  static Future<T> logGroupAsync<T>(
    String title,
    FutureOr<T> Function() body,
  ) async {
    print('::group::$title');
    try {
      return await body();
    } finally {
      print('::endgroup::');
    }
  }

  static Future<void> runZoned(
    FutureOr<void> Function() main, {
    bool setExitCode = true,
  }) async =>
      runZonedGuarded(main, (error, stack) {
        logError(error.toString());
        logGroup('Stack-Trace', () => print(stack));
        if (setExitCode) {
          exitCode = 1;
        }
      });
}
