import '../../../scripts/publish.dart';

Future<void> main(List<String> args) => publish(
      args,
      flutter: true,
      clearFiles: const ['android/src/main/.gitignore'],
      rmFiles: const ['example/windows/flutter/ephemeral/.plugin_symlinks'],
    );
