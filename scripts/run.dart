import 'dart:io';

class ChildErrorException implements Exception {
  final int exitCode;

  ChildErrorException(this.exitCode);
}

Future<void> run(String executable, List<String> arguments) async {
  stdout.writeln('> Running $executable ${arguments.join(' ')}');
  final process = await Process.start(
    executable,
    arguments,
    mode: ProcessStartMode.inheritStdio,
  );
  final exitCode = await process.exitCode;
  if (exitCode != 0) {
    throw ChildErrorException(exitCode);
  }
}