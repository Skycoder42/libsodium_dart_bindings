import 'dart:io';

import 'package:dart_test_tools/tools.dart';
import 'package:path/path.dart';

import 'libsodium_js_generator/file_loader.dart';
import 'libsodium_js_generator/generators/constants_generator.dart';
import 'libsodium_js_generator/generators/library_generator.dart';
import 'libsodium_js_generator/generators/symbols_generator.dart';
import 'libsodium_js_generator/repo_loader.dart';
import 'libsodium_js_generator/type_mappings.dart';

// ignore: directives_ordering
import '../../sodium_libs/libsodium_version.dart' show libsodium_version;

Future<void> main() async {
  final repoLoader = RepoLoader();
  final wrapperDir = await repoLoader.downloadRepo(libsodium_version.js);
  final fileLoader = FileLoader(wrapperDir);

  final typeMappings = TypeMappings();
  const libraryGenerator = LibraryGenerator();
  final constantsGenerator = ConstantsGenerator(typeMappings);
  final symbolsGenerator = SymbolsGenerator(typeMappings);

  final outFile = File(
    join(
      FileLoader.scriptDir.path,
      '..',
      'lib',
      'src',
      'js',
      'bindings',
      'sodium.js.dart',
    ),
  );
  final outSink = outFile.openWrite();

  try {
    libraryGenerator.writeImports(outSink);

    await typeMappings.writeTypeDefinitions(outSink);

    libraryGenerator.writeClassPre(outSink);

    constantsGenerator.writeDefinitions(
      await fileLoader.loadFileJson('constants.json'),
      outSink,
      1,
    );

    final symbolDataStream = fileLoader.loadFilesJson(
      'symbols',
      (file) => file.path.endsWith('.json'),
    );
    await for (final symbolData in symbolDataStream) {
      symbolsGenerator.writeDefinitions(symbolData, outSink, 1);
    }

    libraryGenerator
      ..writeExtraDefinitions(outSink, 1)
      ..writeClassPost(outSink);
  } finally {
    await outSink.close();
  }

  await Github.exec('dart', ['format', '--fix', outFile.path]);
}
