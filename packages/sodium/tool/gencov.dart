import 'dart:io';

import 'package:args/args.dart';

import '../../../scripts/run.dart';

const _platformVm = 'vm';
const _platformJs = 'js';
const _allPlatforms = [_platformVm, _platformJs];

Future<void> main(List<String> rawArgs) async {
  final parser = ArgParser(allowTrailingOptions: false)
    ..addMultiOption(
      'platforms',
      abbr: 'p',
      allowed: _allPlatforms,
      defaultsTo: _allPlatforms,
    )
    ..addFlag('clean', abbr: 'c', defaultsTo: true)
    ..addFlag('open', abbr: 'o')
    ..addFlag('help', abbr: 'h', negatable: false);

  final args = parser.parse(rawArgs);
  if (args['help'] as bool) {
    stdout.writeln(parser.usage);
    return;
  }

  try {
    final testPlatforms = args['platforms'] as List<String>;
    final clean = args['clean'] as bool;
    final open = args['open'] as bool;

    final coverageDir = Directory('coverage');
    if (await coverageDir.exists()) {
      await Directory('coverage').delete(recursive: true);
    }

    if (testPlatforms.contains(_platformVm)) {
      await _runDart([
        'test',
        '--coverage=coverage/vm',
        'test/unit',
      ]);
    }
    if (testPlatforms.contains(_platformJs)) {
      await _runDart([
        'test',
        '-p',
        'chrome',
        '--coverage=coverage/js',
        'test/unit',
      ]);
    }

    await _runDart(const [
      'run',
      'coverage:format_coverage',
      '--lcov',
      '--check-ignore',
      '--in=coverage',
      '--out=coverage/lcov.info',
      '--packages=.packages',
      '--report-on=lib',
    ]);

    if (clean) {
      await run(
        'lcov',
        const [
          '--remove',
          'coverage/lcov.info',
          '--output-file',
          'coverage/lcov_cleaned.info',
          '**/*.freezed.dart',
          '**/*.ffi.dart',
          '**/*.js.dart',
        ],
      );
    }

    await run(
      'genhtml',
      [
        '--no-function-coverage',
        '-o',
        'coverage/html',
        'coverage/${clean ? 'lcov_cleaned' : 'lcov'}.info',
      ],
    );

    if (open) {
      String executable;
      if (Platform.isLinux) {
        executable = 'xdg-open';
      } else if (Platform.isWindows) {
        executable = 'start';
      } else if (Platform.isMacOS) {
        executable = 'open';
      } else {
        throw UnsupportedError(
          '${Platform.operatingSystem} is not supported',
        );
      }
      await run(executable, const ['coverage/html/index.html']);
    }
  } on ChildErrorException catch (e) {
    exitCode = e.exitCode;
  }
}

Future<void> _runDart(List<String> arguments) => run('dart', arguments);
