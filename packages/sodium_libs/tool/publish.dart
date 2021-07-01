import '../../../scripts/publish.dart';

Future<void> main(List<String> args) => publish(
      args,
      clearFiles: const ['android/src/main/.gitignore'],
    );
