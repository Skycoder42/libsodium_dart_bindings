import 'dart:io';

import 'package:args/args.dart';

import '../../../scripts/run.dart';

const _modeUnit = 'unit';
const _modeIntegration = 'integration';
const _platformVm = 'vm';
const _platformJs = 'js';

Future<void> main(List<String> rawArgs) async {
  final parser = ArgParser(allowTrailingOptions: false)
    ..addMultiOption(
      'platforms',
      abbr: 'p',
      allowed: const [_platformVm, _platformJs],
      defaultsTo: const [_platformVm, _platformJs],
    )
    ..addMultiOption(
      'modes',
      abbr: 'm',
      allowed: const [_modeUnit, _modeIntegration],
      defaultsTo: const [_modeUnit, _modeIntegration],
    )
    ..addFlag('coverage', abbr: 'c')
    ..addFlag('open-coverage', abbr: 'o')
    ..addFlag('sumo')
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
    );

  final args = parser.parse(rawArgs);
  if (args['help'] as bool) {
    stdout.writeln(parser.usage);
    return;
  }

  try {
    final testModes = args['modes'] as List<String>;
    final testPlatforms = args['platforms'] as List<String>;
    final coverage = args['coverage'] as bool;
    final openCoverage = args['open-coverage'] as bool;

    if (testModes.contains(_modeUnit)) {
      if (coverage) {
        final coverageDir = Directory('coverage');
        if (await coverageDir.exists()) {
          await Directory('coverage').delete(recursive: true);
        }
      }

      if (testPlatforms.contains(_platformVm)) {
        await _runDart([
          'test',
          if (coverage) '--coverage=coverage',
          'test/unit/api',
          'test/unit/ffi',
        ]);
      }
      if (testPlatforms.contains(_platformJs)) {
        await _runDart([
          'test',
          '-p',
          'chrome',
          if (coverage) '--coverage=coverage',
          'test/unit/api',
          'test/unit/js',
        ]);
      }

      if (coverage) {
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

        if (openCoverage) {
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
          await run(
            'genhtml',
            [
              '--no-function-coverage',
              '-o',
              'coverage/html',
              'coverage/lcov_cleaned.info',
            ],
          );
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
      }
    }

    if (testModes.contains(_modeIntegration)) {
      if (testPlatforms.contains(_platformVm)) {
        await _runDart(const ['test', 'test/integration/vm_test.dart']);
      }
      if (testPlatforms.contains(_platformJs)) {
        final sumo = args['sumo'] as bool;
        await _runDart([
          'test',
          '-p',
          'chrome',
          if (sumo)
            'test/integration/js_test_sumo.dart'
          else
            'test/integration/js_test.dart',
        ]);
      }
    }
  } on ChildErrorException catch (e) {
    exitCode = e.exitCode;
  }
}

Future<void> _runDart(List<String> arguments) => run('dart', arguments);
