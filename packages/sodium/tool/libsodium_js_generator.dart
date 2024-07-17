import 'dart:io';

import 'package:code_builder/code_builder.dart';
import 'package:dart_test_tools/tools.dart';
import 'package:path/path.dart';

import 'libsodium_js_generator/generators/library_generator.dart';
import 'libsodium_js_generator/generators/test/test_library_generator.dart';
import 'libsodium_js_generator/loaders/constants_loader.dart';
import 'libsodium_js_generator/loaders/file_loader.dart';
import 'libsodium_js_generator/loaders/repo_loader.dart';
import 'libsodium_js_generator/loaders/symbols_loader.dart';
import 'libsodium_js_generator/loaders/type_mappings_loader.dart';

// ignore: directives_ordering
import '../../sodium_libs/libsodium_version.dart' show libsodium_version;

Future<void> main() async {
  final repoLoader = RepoLoader();

  final wrapperDir = await repoLoader.downloadRepo(libsodium_version.js);
  final wrapperLoader = FileLoader(wrapperDir);

  final sourceDir = Directory(
    join(FileLoader.scriptDir.path, 'libsodium_js_generator'),
  );
  final sourceLoader = FileLoader(sourceDir);

  final typeMappings = TypeMappingsLoader(sourceLoader);
  final constantsLoader = ConstantsLoader(wrapperLoader);
  final symbolsLoader = SymbolsLoader(wrapperLoader);

  final libraryGenerator = LibraryGenerator(
    typeMappings,
    constantsLoader,
    symbolsLoader,
  );
  final library = await libraryGenerator.build();

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
  await _generate(outFile, library);

  final testLibraryGenerator = TestLibraryGenerator(
    typeMappings,
    constantsLoader,
    symbolsLoader,
  );
  final testLibrary = await testLibraryGenerator.build();
  final testFile = File(
    join(
      FileLoader.scriptDir.path,
      '..',
      'test',
      'unit',
      'js',
      'sodium_js_mock.dart',
    ),
  );
  await _generate(testFile, testLibrary);
}

Future<void> _generate(File outFile, Library library) async {
  final outSink = outFile.openWrite();
  try {
    final emitter = DartEmitter(
      orderDirectives: true,
      useNullSafetySyntax: true,
    );
    library.accept(emitter, outSink);
    await outSink.flush();
  } finally {
    await outSink.close();
  }

  await Github.exec('dart', ['format', '--fix', outFile.path]);
  await Github.exec('dart', ['fix', '--apply', outFile.path]);
}
