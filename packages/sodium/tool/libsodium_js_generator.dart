import 'dart:io';

import 'package:code_builder/code_builder.dart';
import 'package:dart_test_tools/tools.dart';
import 'package:path/path.dart';

import 'libsodium_js_generator/generators/library_generator.dart';
import 'libsodium_js_generator/generators/test/test_library_generator.dart';
import 'libsodium_js_generator/json/library_info.dart';
import 'libsodium_js_generator/loaders/constants_loader.dart';
import 'libsodium_js_generator/loaders/file_loader.dart';
import 'libsodium_js_generator/loaders/library_info_loader.dart';
import 'libsodium_js_generator/loaders/repo_loader.dart';
import 'libsodium_js_generator/loaders/symbols_loader.dart';
import 'libsodium_js_generator/loaders/type_mappings_loader.dart';

// ignore: directives_ordering
import '../../sodium_libs/libsodium_version.dart' show libsodium_version;

Future<void> main() async {
  final libraryInfo = await _loadLibraryInfo();

  await _generate(
    LibraryGenerator(libraryInfo),
    File(
      join(
        FileLoader.scriptDir.path,
        '..',
        'lib',
        'src',
        'js',
        'bindings',
        'sodium.js.dart',
      ),
    ),
  );

  await _generate(
    TestLibraryGenerator(libraryInfo),
    File(
      join(
        FileLoader.scriptDir.path,
        '..',
        'test',
        'unit',
        'js',
        'sodium_js_mock.dart',
      ),
    ),
  );
}

Future<LibraryInfo> _loadLibraryInfo() async {
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
  final libraryInfoLoader = LibraryInfoLoader(
    typeMappings,
    constantsLoader,
    symbolsLoader,
  );

  return await libraryInfoLoader.load();
}

Future<void> _generate(Spec codeSpec, File outFile) async {
  final outSink = outFile.openWrite();
  try {
    final emitter = DartEmitter(
      orderDirectives: true,
      useNullSafetySyntax: true,
    );
    codeSpec.accept(emitter, outSink);
    await outSink.flush();
  } finally {
    await outSink.close();
  }

  await Github.exec('dart', ['format', '--fix', outFile.path]);
  await Github.exec('dart', ['fix', '--apply', outFile.path]);
  await Github.exec('dart', ['format', '--fix', outFile.path]);
}
