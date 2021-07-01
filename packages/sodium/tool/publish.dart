import '../../../scripts/publish.dart';

Future<void> main(List<String> args) => publish(
      args,
      clearFiles: const ['lib/src/.gitignore'],
    );
