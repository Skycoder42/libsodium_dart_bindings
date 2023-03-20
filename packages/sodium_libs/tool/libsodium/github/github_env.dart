import 'dart:io';

import '../../../../../tool/util.dart';

abstract class GithubEnv {
  GithubEnv._();

  static Directory get runnerTemp {
    final runnerTemp = Platform.environment['RUNNER_TEMP'];
    return runnerTemp != null ? Directory(runnerTemp) : Directory.systemTemp;
  }

  static Directory get githubWorkspace {
    final githubWorkspace = Platform.environment['GITHUB_WORKSPACE'];
    return githubWorkspace != null
        ? Directory(githubWorkspace)
        : Directory.current.subDir('../..');
  }

  static Future<void> setOutput(
    String name,
    Object? value, {
    bool multiline = false,
  }) async {
    final githubOutput = Platform.environment['GITHUB_OUTPUT'];
    if (githubOutput == null) {
      throw Exception('Cannot set output! GITHUB_OUTPUT env var is not set');
    }

    final githubOutputFile = File(githubOutput);
    if (multiline) {
      await githubOutputFile.writeAsString(
        '$name<<EOF\n${value}EOF\n',
        mode: FileMode.append,
      );
    } else {
      await githubOutputFile.writeAsString(
        '$name=$value\n',
        mode: FileMode.append,
      );
    }
  }
}
